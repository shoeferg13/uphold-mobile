//
//  SuggestedCommunication.swift
//  UpHoldMobile
//
//  Created by Shannon Ferguson on 7/29/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit
import EventKit
import Alamofire

class SuggestedCommunication: UIViewController {
    
    override func viewDidLoad() {
        //self.optionOneButton.titleLabel?.text = self.allTrends[Int.random(in: 0..<self.allTrends.count)].title
        if self.allTrends.count > 0 {
            trendIndex = Int.random(in: 0..<self.allTrends.count)
            self.optionOneButton.setTitle(self.allTrends![trendIndex].title, for: .normal)
        }
    }
    
    var currentClient: ClientModel!
    var allTrends: [TrendsModel]!
    var trendIndex: Int!
    var startDate: String!
    var endDate: String!
    var titleString: String!
    let months = ["01": "January", "02": "February", "03": "March", "04": "April", "05": "May", "06": "June", "07": "July", "08": "August", "09": "September", "10": "October", "11": "November", "12": "December"]
    @IBOutlet weak var suggestionlabel: UILabel! {
        didSet {
            getSuggestCom()
        }
    }
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var optionOneButton: UIButton! {
        didSet {
            self.optionOneButton.titleLabel?.numberOfLines = 0
            self.optionOneButton.titleLabel?.textAlignment = .center
        }
    }
    
    
    @IBAction func addCalendarTap(_ sender: Any) {
        let eventStore:EKEventStore = EKEventStore()
        self.addToClientCalender(eventStore: eventStore, title: titleString, whenDate: startDate, expirationDate: endDate)
    }
    
    @IBAction func optionOnPress(_ sender: Any) {
        print("trend pressed")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //segues information into ClientSummaryViewController
        let vc = segue.destination as! ClientsWebViewController
        vc.trendsIndex = trendIndex
        vc.allTrends = self.allTrends
    }
    
    func getSuggestCom() {
        let baseURL = "https://dev-uphold-backend.labs.fulcrumgt.com/sug_act/get_sug_act/?Content"
        let myParameters: Parameters = ["client_id" : self.currentClient.id]
        Alamofire.request(baseURL, method: .post, parameters: myParameters, encoding: JSONEncoding.default, headers: appUser.myHeader).responseJSON { response in
            if response.response!.statusCode < 400 {
                print("sucesss")
                let json = try? JSONSerialization.jsonObject(with: response.data!, options: [])
                print(json)
                let clientEvent = json as! [String: Any]
                let whenDate = clientEvent["when"]
                let expirationDate = clientEvent["expiration_date"]
                self.suggestionlabel.text?.append(expirationDate as! String)
                let suggestions = clientEvent["personal_info"] as! [String]
                let titleString = suggestions[Int.random(in: 0..<suggestions.count)]
                self.startDate = whenDate as! String
                self.endDate = expirationDate as! String
                self.titleString = titleString as! String
                self.suggestionlabel.text = "We suggest sending this communication by "
                self.suggestionlabel.text?.append(self.getDate(myDate: self.endDate))
                self.eventLabel.text = "Personal: " + titleString
                self.startDateLabel.text = "Suggested Date: " + self.startDate
                self.endDateLabel.text = "Latest Date: " + self.endDate
                print(self.startDate + " : " + self.endDate + " : " + self.titleString)
            } else {
                print(response.response?.statusCode)
                print("fail")
            }
        }
    }
    
    func addToClientCalender(eventStore: EKEventStore, title: String, whenDate: String, expirationDate: String) {
        eventStore.requestAccess(to: .event, completion: {(granted, error) in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                let event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = self.stringToDate(stringDate: whenDate)
                event.endDate = self.stringToDate(stringDate: expirationDate)
                event.notes = "This is a note"
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("error: \(error)")
                }
                print("Save event")
            } else {
                print("error : \(error)")
            }
        })
    }
    
    func stringToDate(stringDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: stringDate) ?? Date()
        print("date: \(date)")
        return date
    }
    
    func getDate(myDate: String) -> String {
        let tempDate = myDate
        let year = tempDate.prefix(4)
        
        let monthStart = tempDate.index(tempDate.startIndex, offsetBy: 5)
        let monthEnd = tempDate.index(tempDate.endIndex, offsetBy: -3)
        let range = monthStart..<monthEnd
        let myMonth = tempDate[range]
        
        let dayStart = tempDate.index(tempDate.startIndex, offsetBy: 8)
        let dayEnd = tempDate.index(tempDate.endIndex, offsetBy: 0)
        let dayrange = dayStart..<dayEnd
        let myDay = tempDate[dayrange]
        var date = months[String(myMonth)]! + " " + myDay + "th " + year
        return date
    }
    
    
}
