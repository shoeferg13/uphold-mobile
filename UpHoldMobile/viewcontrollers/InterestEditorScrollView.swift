import UIKit
import Alamofire

class InterestEditorScrollView: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate  {
    
    @IBOutlet weak var interestEditorSearch: UISearchBar! {
        didSet {
            self.interestEditorSearch.delegate = self
        }
    }
    
    var tempData = [[String: Any]]()    //array of json objects as users, needs to be parsed into userData
    var userData = [ClientModel]()
    
    var clientsName: String?
    var clientPic: UIImage?
    let tempImage = UIImage(named: "Egg_Uphold")
    var tempUserData = [ClientModel]()
    var clientName: String? //clientsName
    var clientCompany: String?  //clients Company
    var clientIndex: Int?   //index used to keep track of which cell was selected
    let phoneSize = UIScreen.main.bounds
    var clientsUsername: String?
    var keywords = [String: [String]]()
    var allTrends = [TrendsModel]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! InterestEditorClientCell
        let myClient = userData[indexPath.row]
        clientsName = myClient.first_name! + " " + myClient.last_name!
        print("THIS IS CLIENTS NAME" + "\(clientsName)")
        cell.clientName.text = clientsName
        cell.clientProfilePic.image = tempImage
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clientList.rowHeight = clientList.frame.height / 4
        //        let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
        //        tap.cancelsTouchesInView = false
        //        self.view.addGestureRecognizer(tap)
        self.populateClients()
    }
    
    @IBOutlet weak var clientList: UITableView! {
        didSet{
            clientList.delegate = self
            clientList.dataSource = self
            
        }
    }
    
    func populateClients() {    //for now it is a O(n^2) solution, but will find a better way doing it
        let myUser: Parameters = ["username" : appUser.appUserUsername!]
        Alamofire.request("https://dev-uphold-backend.labs.fulcrumgt.com/user/clients/", method: .get, parameters: myUser, encoding: JSONEncoding.default, headers: appUser.myHeader).responseJSON { response in
            let json = try? JSONSerialization.jsonObject(with: response.data!, options: [])
            if let myResponse = json as? [String: Any] {
                let unparsedClients = myResponse["clients"] as! [[String: Any]] //array of dictionaries, clients
                
                for dic in unparsedClients {
                    var tempClient = ClientModel(dic)
                    if let matterArr = dic["matters"] as? [[String: Any]] { //array of dics for the matters, recieved from each client
                        
                        for clientMatters in matterArr {  //loops through matters
                            var tempMatter: MatterModel!
                            tempMatter = MatterModel(clientMatters)  //init matter)
                            tempClient.matters.append(tempMatter) //adds matters to the specific client
                        }
                        
                        if let preferenceArr = dic["preferences"] as? [[String: Any]] { //preference version of matters
                            for clientPreference in preferenceArr {
                                var tempPreference: PreferenceModel!
                                tempPreference = PreferenceModel(clientPreference)
                                tempClient.preferences.append(tempPreference)
                            }
                        }
                        
                        if let sig_datesArr = dic["sig_dates"] as? [[String: Any]] {    //sig_dates version of matters
                            for clientSig_Dates in sig_datesArr {
                                var tempSig_Dates: Sig_DatesModel!
                                tempSig_Dates = Sig_DatesModel(clientSig_Dates)
                                tempClient.sig_dates.append(tempSig_Dates)
                            }
                        }
                        
                        
                        if let family_arr = dic["family"] as? [[String: Any]] {    //family version of matters
                            for clientFamily in family_arr {
                                tempClient.family.append(clientFamily["name"] as! String)
                            }
                        }
                        
                        tempClient.interestsNames = self.getInterests(preferences: tempClient.preferences)
                        tempClient.dislikes = self.getDislikes(preferences: tempClient.preferences)
                        tempClient.eventNames = self.getEvents(events: tempClient.sig_dates)
                        tempClient.clientDic[0] = tempClient.family
                        tempClient.clientDic[1] = tempClient.interestsNames
                        tempClient.clientDic[2] = tempClient.dislikes
                        tempClient.clientDic[3] = tempClient.eventNames //lines above updates clients dictionary which will be segued to other features
                        tempClient.clientDic[4] = self.getWeights(preferences: tempClient.preferences, checker: 0)  //adds interest weights to dictionary
                        tempClient.clientDic[5] = self.getWeights(preferences: tempClient.preferences, checker: 1)  //adds dislikes weights to dictionary
                        tempClient.clientDic[6] = self.keywords[tempClient.company!]    //gets keywords based off of clients company
                        self.tempUserData.append(tempClient)
                    }
                }
            }
            self.userData = self.tempUserData
            self.clientList.reloadData()
        }
    }
    
    
    
    func getKeywords() {
        Alamofire.request("https://dev-uphold-backend.labs.fulcrumgt.com/user/companies/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: appUser.myHeader).responseJSON { response in
            let json = try? JSONSerialization.jsonObject(with: response.data!, options: [])
            if let myResponse = json as? [[String: Any]] {
                for temp in myResponse {
                    var keywordCompany: String = (temp["name"] as? String)!
                    if !self.keywords.keys.contains(keywordCompany) {
                        self.keywords[keywordCompany] = temp["keywords"] as! [String]
                        print(self.keywords)
                    }
                }
            }
        }
    }
    
    func getTrends() {  //get function for trends
        var baseURL = "https://dev-uphold-backend.labs.fulcrumgt.com/sug_act/trends/"
        Alamofire.request(baseURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: appUser.myHeader).responseJSON {response in
            let json = try? JSONSerialization.jsonObject(with: response.data!, options: [])
            //debugPrint(json)
            if let trends = json as? [[String: Any]] {
                for index in 0..<trends.count {
                    self.allTrends.append(TrendsModel(trends[index]))   //creates a TrendModel objectg
                }
            }
        }
    }
    
    
    
    func getInterests(preferences: [PreferenceModel]) -> [String] {
        var interests = [String]()
        for clientPref in preferences {
            if clientPref.positive! {
                interests.append(clientPref.title)
            }
        }
        return interests
    }
    
    func getDislikes(preferences: [PreferenceModel]) -> [String] {
        var dislikes = [String]()
        for clientDis in preferences {
            if !clientDis.positive! {
                dislikes.append(clientDis.title)
            }
        }
        return dislikes
    }
    
    func getWeights(preferences: [PreferenceModel], checker: Int) -> [String] {
        var weights = [String]()
        if checker == 0 {
            for tempPref in preferences {
                if tempPref.positive! {
                    weights.append(String(tempPref.weight!))
                }
            }
        } else {
            for tempPref in preferences {
                if !tempPref.positive! {
                    weights.append(String(tempPref.weight!))
                }
            }
        }
        return weights
    }
    
    func getEvents(events: [Sig_DatesModel]) -> [String]{
        var result = [String]()
        for clientEvents in events {
            if clientEvents.name != nil {
                result.append(clientEvents.name)
            }
        }
        return result
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {    //searches through users and looks for clients that meet the serachTexts critera
        userData = searchText.isEmpty ? tempUserData : tempUserData.filter({ (someClient) -> Bool in
            let clientInformation = someClient.first_name! + " " + someClient.last_name! + " " + someClient.company!
            return clientInformation.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        clientList.reloadData()
    }
    
}
