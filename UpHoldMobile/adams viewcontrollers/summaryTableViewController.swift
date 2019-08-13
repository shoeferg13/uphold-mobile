//
//  summaryTableViewController.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/12/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//
import UIKit
import Alamofire

class summaryTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.tableView.rowHeight = tableView.frame.height / 5
        self.tableView.tableFooterView = UIView() //gets rid of empty cells
        //self.tableView.allowsSelection = false  //disables click on tableViews
    }
    
    // MARK: - Table view data source
    var clientsName: String?
    var typeIndex: Int = 3
    var matters = [MatterModel]()
    var clientDics = [Int: [String]]()  // 0: family, 1: interests, 2: dislikes, 3: eventnames, 4: interests weights, 5: dislikes weights, 6: client keywords
    var types = [String]()
    var personalTypes = ["Family", "Interests", "Dislikes", "Events"]
    var headLineTitles = ["To refresh your memory", "Keep it personal", "Stay current"]
    var clientsComapny: String = ""
    var clientsPostion: String = ""
    var clientsDepartment: String = ""
    var clientsPhone: String = ""
    var clientsEmail: String = ""
    var currentClient: ClientModel!
    let months = ["01": "January", "02": "February", "03": "March", "04": "April", "05": "May", "06": "June", "07": "July", "08": "August", "09": "September", "10": "October", "11": "November", "12": "December"]
    
    override func numberOfSections(in tableVigitew: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch typeIndex {
        case 0:
            return matters.count
        case 1:
            return 2    //client info and keywords
        case 2:
            return personalTypes.count
        case 3:
            return 3 - 1 // change back when stay current cell is made
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if typeIndex == 0 { //legalTab
            let cell = tableView.dequeueReusableCell(withIdentifier: "legalCell") as! legalCell
            
            let tempMatter = matters[indexPath.row]
            cell.startLabel?.text = "" + getDate(myDate: tempMatter.startDate!)
            cell.endLabel?.text = "" + getDate(myDate: tempMatter.endDate!)
            cell.typeLabel?.text = tempMatter.title!
            let tempPartners = getPartners(partners: tempMatter.partners!)
            if tempPartners == "" {
                cell.partnerLabel?.text = "None"
            } else {
                cell.partnerLabel?.text = getPartners(partners: tempMatter.partners!)
            }
            self.tableView.rowHeight = ((cell.startLabel?.bounds.height)! + (cell.endLabel?.bounds.height)! + (cell.typeLabel?.bounds.height)! + (cell.typeLabel?.bounds.height)!) * CGFloat(2.5)
            return cell
        }
        else if typeIndex == 1{ //professional tab
            if indexPath.row == 0 { //Client information cell
                let cell = tableView.dequeueReusableCell(withIdentifier: "professionalCell") as! professionalCell
                cell.companyLabel?.text = clientsComapny
                cell.positionLabel?.text = clientsPostion
                cell.divisionLabel?.text = clientsDepartment
                cell.PhoneLabel?.text = clientsPhone
                cell.emailLabel?.text = clientsEmail
                self.tableView.rowHeight = ((cell.companyLabel?.bounds.height)! + (cell.positionLabel?.bounds.height)! + (cell.divisionLabel?.bounds.height)! + (cell.PhoneLabel?.bounds.height)! + (cell.emailLabel?.bounds.height)!) * CGFloat(1.75)
                return cell
            } else {    //keyword cells
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfessionalKeyWordCell") as! ProfessionalKeyWordCell
                cell.keywordTitleLabel.text = "Keywords"
                let currHeight = Int(Int(cell.keywordTitleLabel.frame.origin.y)) + 30
                cell.currHeight = currHeight
                cell.display(clientKeywords: clientDics[6]!)
                self.tableView.rowHeight = CGFloat(cell.currHeight + Int(cell.keywordTitleLabel.bounds.height)) * CGFloat(1)
                return cell
            }
            
        }
        else if typeIndex == 2{ //personal tab
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell") as! personalCell
            cell.personalTitleLabel.text = personalTypes[indexPath.row]
            let tempCurr = clientDics[indexPath.row]
            var currHeight = Int(Int(cell.personalTitleLabel.frame.origin.y))
            let newHeight:Double = Double(currHeight)
            
            var weights = [String]()
            if indexPath.row == 1 { //sets weights to be interest weights if the section is index of 1
                weights = clientDics[4]!
            }
            if indexPath.row == 2 { //sets weights to be dislikes weights if the section is index of 2
                weights = clientDics[5]!
            }
            
            cell.currHeight = currHeight
            cell.currentClient = self.currentClient
            cell.display(tempCurr: tempCurr!, weights: weights, myIndexPath: indexPath.row, likesCount: clientDics[1]!.count)
            cell.delegate = self
            self.tableView.rowHeight = CGFloat(cell.myRowHeight + Int(cell.personalTitleLabel.bounds.height)) * CGFloat(1.5)  //cell.myRowHeight
            return cell
        }
        else if typeIndex == 3 { //suggestcom, screen before anyone of the tabs are selected
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestedComCell") as! suggestedComCell
            let tempMatter = matters[indexPath.row]
            cell.headLineLabel.text = headLineTitles[indexPath.row]
            
            if indexPath.row == 0 { //firstCell in the suggestCom page
                cell.headLineStartLabel.text = "Start Date: " + getDate(myDate: tempMatter.startDate!)
                cell.headLineEndLabel.text = "End Date: " + getDate(myDate: tempMatter.endDate!)
                cell.headLineTypeLabel.text = "Type: " + tempMatter.title!
            }
            if indexPath.row == 1 { //secondCell in the suggestCom page
                cell.headLineStartLabel.text = "Remember, " + clientsName! + " is a fan of "
                let tempInterestArr = clientDics[1]
                cell.headLineEndLabel.text = tempInterestArr?.randomElement() ?? "henlo"
                cell.headLineEndLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
                cell.headLineTypeLabel.text = ""
            }
            self.tableView.rowHeight = (cell.headLineStartLabel.bounds.height + cell.headLineEndLabel.bounds.height + cell.headLineTypeLabel.bounds.height) * CGFloat(2.25)
            return cell
        }
        
        
        
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "legalCell") as! legalCell
        return defaultCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //Segues into ClientSummaryViewController
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func getPartners(partners: [String]) -> String {
        var tempPartners = ""
        for index in 0..<partners.count {
            tempPartners += partners[index] + ", "
        }
        return tempPartners
    }
    
    func arrayToList(arr: [String]) -> String {
        var tempList = ""
        for index in 0..<arr.count {
            tempList += "\u{2022} " + arr[index] + "\n"
        }
        return tempList
    }
    
    func heightForRow(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func getDate(myDate: String) -> String {
        let tempDate = myDate
        let year = tempDate.prefix(4)
        
        let monthStart = tempDate.index(tempDate.startIndex, offsetBy: 5)
        let monthEnd = tempDate.index(tempDate.endIndex, offsetBy: -17)
        let range = monthStart..<monthEnd
        let myMonth = tempDate[range]
        
        let dayStart = tempDate.index(tempDate.startIndex, offsetBy: 8)
        let dayEnd = tempDate.index(tempDate.endIndex, offsetBy: -14)
        let dayrange = dayStart..<dayEnd
        let myDay = tempDate[dayrange]
        
        var date = months[String(myMonth)]! + " " + myDay + " " + year
        return date
    }
}
