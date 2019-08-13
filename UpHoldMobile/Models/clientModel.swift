//
//  clientModel.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 6/27/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import Foundation

struct ClientModel: Codable {   //object for client, sets all variables based on api
    var id: Int!
    var age: Int!
    var department: String?
    var family = [String]()
    var first_name: String?
    var last_name: String?
    var matters = [MatterModel]() //array of all matters
    var preferences = [PreferenceModel]()
    var position: String?
    var profile_picture: String?
    var sig_dates = [Sig_DatesModel]()
    var interestsNames = [String]()    //a list of all the names of preferences
    var dislikes = [String]()  //a list of all the names of dislikes
    var eventNames = [String]()
    var clientDic = [Int: [String]]()
    var company: String?
    var clientJSON: ClientJSONModel!
    var email: String?
    var phone_number: String?
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as! Int
        self.age = dictionary["age_of_relationship"] as! Int
        self.department = dictionary["department"] as? String ?? nil
        self.first_name = dictionary["firstname"] as? String ?? nil
        self.last_name = dictionary["lastname"] as? String ?? nil
        self.position = dictionary["position"] as? String ?? nil
        if dictionary["profile_picture"] as? String == "null" {
            self.profile_picture = "placeholder"
        }
        self.profile_picture = dictionary["profile_picture"] as? String ?? nil
        self.company = dictionary["company"] as? String ?? nil
        self.email = dictionary["email"] as? String ?? nil
        self.phone_number = dictionary["phone_number"] as? String ?? nil
    }
}

struct MatterModel: Codable {
    var partners: [String]?
    var caseID: String?
    var title: String?
    var startDate: String?
    var endDate: String?
    
    
    init(_ dictionary: [String: Any]) {
        self.partners = dictionary["partners_involved"] as? [String] ?? nil
        self.caseID = dictionary["_id"] as? String ?? nil
        self.title = dictionary["title"] as? String ?? nil
        self.startDate = dictionary["start"] as? String ?? nil
        self.endDate = dictionary["end"] as? String ?? nil
    }
    
}

struct PreferenceModel: Codable {
    //var id: String?
    var category: String!
    var positive: Bool!
    var title: String!
    var weight: Int?
    var timestamp = "2019/05/23"
    
    init(_ dictionary: [String: Any]) {
        //self.id = dictionary["_id"] as? String ?? nil
        self.category = dictionary["category"] as? String ?? nil
        if dictionary["positive"] as! Int == 1 {
            self.positive = true
        } else {
            self.positive = false
        }
        self.title = dictionary["title"] as? String ?? nil
        self.weight = dictionary["weight"] as! Int
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "category" : self.category,
            "positive" : self.positive,
            "title" : self.title,
            "weight" : self.weight,
            "timestamp" : self.timestamp
        ]
    }
}

struct Sig_DatesModel: Codable {
    var id: String?
    var name: String!
    var preferences = [PreferenceModel]()
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["_id"] as? String ?? nil
        self.name = dictionary["name"] as? String ?? nil
    }
}

struct TrendsModel: Codable {
    var title: String!
    var url: String!
    var time_published: String!
    var relevancy: Int!
    
    init(_ dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String ?? nil
        self.url = dictionary["url"] as? String ?? nil
        self.time_published = dictionary["time_published"] as? String ?? nil
        self.relevancy = dictionary["relevancy_score"] as! Int
    }
}

struct appUser {
    static var appUserUsername: String?
    static var appUserToken: String?
    static var appUserPhone: String?
    static var appUserEmail: String?
    
    static var myHeader = [
        "Authorization" : appUserToken!,
        "Content-Type" : "application/json"
    ]
}

struct ClientPutModel: Encodable {
    var username: String!
    var firstname: String!
    var lastname: String!
    var company: String!
    var position: String!
    var department: String!
    var age_of_relationship: Int!
    var no_registered_matters: Int!
    var preferences = [PreferenceModel]()
    
    init(_ myClient: ClientModel) {
        self.username = appUser.appUserUsername
        self.firstname = myClient.first_name
        self.lastname = myClient.last_name
        self.company = myClient.company
        self.position = myClient.position
        self.department = myClient.department
        self.age_of_relationship = myClient.age
        self.no_registered_matters = myClient.matters.count
        self.preferences = myClient.preferences
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [
            "firstname" : self.firstname,
            "lastname" : self.lastname,
            "company" : self.company,
            "position" : self.position,
            "department" : self.department,
            "age_of_relationship" : self.age_of_relationship,
            "no_registered_matters" : self.no_registered_matters,
            "username" : appUser.appUserUsername
        ]
    }
}

struct ClientJSONModel: Codable {
    var firstname: String!
    var lastname: String!
    var company: String!
    var position: String!
    var department: String!
    var age_of_relationship: Int!
    var no_registered_matters: Int!
    var lawyer_id: String!
    var matters = [MatterModel]()
    var family = [String]()
    var preferences = [PreferenceModel]()
    var sig_dates = [Sig_DatesModel]()
    
    init(_ myClient: ClientModel) {
        self.firstname = myClient.first_name
        self.lastname = myClient.last_name
        self.company = myClient.company
        self.position = myClient.position
        self.department = myClient.department
        self.age_of_relationship = myClient.age
        self.no_registered_matters = myClient.matters.count
        self.matters = myClient.matters
        self.family = myClient.family
        self.preferences = myClient.preferences
        self.sig_dates = myClient.sig_dates
    }
    
}

