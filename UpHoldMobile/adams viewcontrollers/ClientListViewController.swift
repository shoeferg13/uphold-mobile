//
//  ClientListViewController.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 6/28/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//
//import Foundation
import UIKit
import Alamofire

class ClientListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    var button = dropDownButton()
    let tempImage = UIImage(named: "upHold87X87")
    var tempData = [[String: Any]]()    //array of json objects as users, needs to be parsed into userData
    static var userData = [ClientModel]()  //array of clientModels, data is pulled from tempData
    var tempUserData = [ClientModel]()
    var clientName: String? //clientsName
    var clientCompany: String?  //clients Company
    var clientIndex: Int?   //index used to keep track of which cell was selected
    let phoneSize = UIScreen.main.bounds
    var clientsUsername: String?
    var keywords = [String: [String]]()
    var allTrends = [TrendsModel]()
    var age: Int?
    static var needsSorting = false
    

    override func viewWillAppear(_ animated: Bool) {
        self.tempUserData = [ClientModel]()
        ClientListViewController.userData = [ClientModel]()
        self.populateClients()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = tableView.frame.height / 4 //allows only 4 cells to appear on the screen
        let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        button = dropDownButton.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Sort by", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: self.clientSearchBar.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.clientSearchBar.bottomAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    
        
        button.widthAnchor.constraint(equalToConstant: clientSearchBar.frame.width - 15).isActive = true
        button.heightAnchor.constraint(equalToConstant: clientSearchBar.frame.height - 20).isActive = true
        
        button.dropView.dropDownOptions = ["Age of Relationship", "Idle Time"]
     
    }
    
    

    @IBOutlet weak var tableView: UITableView! {    //sets tableView
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            self.getTrends()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            self.navigationItem.hidesBackButton = true  //Prevents back button from appearing on the nav bar, so when client clicks home on tool bar it doesnt show a back option
        }
    }
    
    @IBOutlet weak var clientSearchBar: UISearchBar! {
        didSet {
            self.clientSearchBar.delegate = self
        }
    }
    
    
    func sortAge() {
        
        ClientListViewController.userData.sort(by: {$0.age < $1.age})
        
        var names = [String]()
        for i in 0..<ClientListViewController.userData.count {
            names.append(ClientListViewController.userData[i].first_name!)
            print("Here's a name: \(names[i])")
        }
        
        ClientListViewController.needsSorting = true
        print(ClientListViewController.userData.count)
        print("sorted")
//        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {   //returns the number of cells(clients)
        return ClientListViewController.userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {    //sets up the cells for the tableView
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell") as! ClientCell
        let myClient = ClientListViewController.userData[indexPath.row]
        clientName = myClient.first_name! + " " + myClient.last_name!
        clientCompany = myClient.department!
        cell.clientNameLabel.text = clientName
        cell.clientImage.image = tempImage
        cell.clientCompanyLabel.text = myClient.company
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //Segues into ClientSummaryViewController
        tableView.deselectRow(at: indexPath, animated: true)
        clientIndex = indexPath.row
        self.performSegue(withIdentifier: "summarySeg", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //segues information into ClientSummaryViewController
        let summaryView = segue.destination as! clientSummaryScrollViewController
        let myClient = ClientListViewController.userData[clientIndex!]
        summaryView.clientName = myClient.first_name! + " " + myClient.last_name!
        summaryView.clientPic = tempImage!
        summaryView.clientCompany = myClient.position!
        summaryView.clientActualCompany = myClient.company!
        summaryView.clientDepartment = myClient.department!
        summaryView.clientDictionary = myClient.clientDic
        summaryView.ageofrelation = String(myClient.age!)
        summaryView.clientMatters = myClient.matters
        summaryView.currentClient = myClient
        summaryView.clientsTrends = self.allTrends
        
    }
    
    func populateClients() {    //for now it is a O(n^2) solution, but will find a better way doing it
        let myUser: Parameters = ["username" : appUser.appUserUsername!]
        self.getKeywords()
        Alamofire.request("https://dev-uphold-backend.labs.fulcrumgt.com/user/clients/", method: .get, parameters: myUser, encoding: JSONEncoding.default, headers: appUser.myHeader).responseJSON { response in
            let json = try? JSONSerialization.jsonObject(with: response.data!, options: [])
            //print(json)
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
                        if self.keywords[tempClient.company!] == nil {
                            self.keywords[tempClient.company!] = ["None for now"]
                        }
                        tempClient.clientDic[6] = self.keywords[tempClient.company!]    //gets keywords based off of clients company
                        print(tempClient.clientDic[6]?.count)
                        self.tempUserData.append(tempClient)
                    }
                }
            }
            ClientListViewController.userData = self.tempUserData
            if ClientListViewController.needsSorting {
                self.sortAge()
                ClientListViewController.needsSorting = false
            }
            self.tableView.reloadData()
        }
    }
    
    func getKeywords() {
        var tempKeywords = [String: [String]]()
        Alamofire.request("https://dev-uphold-backend.labs.fulcrumgt.com/user/companies/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: appUser.myHeader).responseJSON { response in
            let json = try? JSONSerialization.jsonObject(with: response.data!, options: [])
            if response.response!.statusCode < 300 {
                //print("success on keywords api")
                print(json)
                if let myResponse = json as? [[String: Any]] {
                    for temp in myResponse {
                        var keywordCompany: String = (temp["name"] as? String)!
                        if !tempKeywords.keys.contains(keywordCompany) {
                            tempKeywords[keywordCompany] = temp["keywords"] as! [String]
                        }
                    }
                }
                self.keywords = tempKeywords
            } else {
                print("failed getting keywords")
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {    //searches through users and looks for clients that meet the serachTexts critera
        ClientListViewController.userData = searchText.isEmpty ? tempUserData : tempUserData.filter({ (someClient) -> Bool in
            let clientInformation = someClient.first_name! + " " + someClient.last_name! + " " + someClient.company!
            return clientInformation.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        tableView.reloadData()
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

}

protocol dropDownProtocol {
    func dropDownPressed(string: String)
}

class dropDownButton: UIButton, dropDownProtocol {
    
    func dropDownPressed(string: String) {
        self.setTitle("Sort by: " + string, for: .normal)
        self.dismissDropDown()
        
    }
    
    var dropView = dropDownView()
    
    var height = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let off_blue = hexStringToUIColor(hex: "E5F6FB")
        self.titleLabel?.textColor = UIColor.black
        self.backgroundColor = off_blue
        
        dropView = dropDownView.init(frame: CGRect.init(x: 0
            , y: 0
            , width: 0
            , height: 0))
        
        dropView.delegate = self
        
        dropView.translatesAutoresizingMaskIntoConstraints = false
    
        
       
        
    }
    
    override func didMoveToSuperview() {
        
        self.superview?.addSubview(dropView)
        self.superview?.bringSubviewToFront(dropView)
        dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    
    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {
            
            isOpen = true
            
            NSLayoutConstraint.deactivate([self.height])
            
            if self.dropView.tableView.contentSize.height > 150 {
            self.height.constant = 150
            } else {
                self.height.constant = self.dropView.tableView.contentSize.height
            }
        
            NSLayoutConstraint.activate([self.height])
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height / 2
            }, completion: nil)
        } else {
            isOpen = false
            
            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            
            NSLayoutConstraint.activate([self.height])
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { self.dropView.center.y -= self.dropView.frame.height / 2
                self.dropView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func dismissDropDown() {
        isOpen = false
        
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        
        NSLayoutConstraint.activate([self.height])
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { self.dropView.center.y -= self.dropView.frame.height / 2
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


func hexStringToUIColor (hex:String) -> UIColor {   //takes a hex number and converts it to the string equiv of a color
    let cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

class dropDownView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var dropDownOptions = [String]()
    
    var tableView = UITableView()
    
    var delegate : dropDownProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate.dropDownPressed(string: dropDownOptions[indexPath.row])
        var balh: ClientListViewController = ClientListViewController()
        balh.sortAge()
        ClientListViewController.needsSorting = true
        print(dropDownOptions[indexPath.row])
    }
    
}



