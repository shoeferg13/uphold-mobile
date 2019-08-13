//
//  InterestEditorViewController.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/9/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit
import Alamofire

class InterestEditorViewController: UIViewController {
 
    
    var clientName: String = ""
    var clientPic: UIImage!
    var clientCompany: String = ""
    var clientActualCompany: String = ""
    var clientDepartment: String = ""
    var ageofrelation: String = ""
    var clientDictionary = [Int: [String]]()
    var clientMatters = [MatterModel]()
    var clientsTrends = [TrendsModel]()
    var currentClient: ClientModel!
    var interest: Int = 1
    @IBOutlet weak var ratingView: Rating!
    @IBOutlet weak var interestButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        ratingView.backgroundColor = UIColor.clear
        
        /** Note: With the exception of contentMode, type and delegate,
         all properties can be set directly in Interface Builder **/
        ratingView.delegate = self as? RatingDelegate
        ratingView.contentMode = UIView.ContentMode.scaleAspectFit
        ratingView.type = .wholeRatings
        
    }
    
  
    @IBOutlet weak var editorTextField: UITextField! {
        didSet {
            self.editorTextField.layer.cornerRadius = 5
            self.editorTextField.layer.borderWidth = 2
            self.editorTextField.layer.borderColor = UIColor.black.cgColor
            self.editorTextField.clipsToBounds = true
        }
    }
    
    
    
    
    @IBOutlet weak var synopsisLabel: UILabel! {
        didSet {
            self.synopsisLabel.text = "A rating on 1 implies that this interest was mentioned rarely in conversation by your client. Similiary a rating of 10 implies that this interest was mentioned with high enthusiasm by your client."
        }
    }
    
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            self.saveButton.layer.cornerRadius = 5
            self.saveButton.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            self.cancelButton.layer.cornerRadius = 5
            self.cancelButton.layer.borderWidth = 1
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func saveOnPress(_ sender: Any) {
        self.updateInterests()  //calls updateInterests to see if the correct parameters have been loaded to allow a new interet to be added
    }
    
    @IBAction func cancelOnPress(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)    //takes user back to previous viewcontroller
    }
    
    
    @IBAction func interestOnPress(_ sender: Any) {
        let originalImage = UIImage(named: "output-onlinepngtools")
        let tintedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        self.interestButton.setImage(tintedImage, for: .normal)
        self.interestButton.tintColor = myHexStringToUIColor(hex: "#F2E8EF")
        self.dislikeButton.tintColor = .black
        interest = 1
    }
    
    
    @IBAction func dislikeOnPress(_ sender: Any) {
        let originalImage = UIImage(named: "output-onlinepngtools (1)")
        let tintedImage = originalImage?.withRenderingMode(.alwaysTemplate)
        self.dislikeButton.setImage(tintedImage, for: .normal)
        self.dislikeButton.tintColor = myHexStringToUIColor(hex: "#E5F8FE")
        self.interestButton.tintColor = .black
        interest = 0

    }
    
    func updateInterests() {
        let baseURL = "https://dev-uphold-backend.labs.fulcrumgt.com/user/clients/" + String(self.currentClient.id) + "/"
        var clientPutParse = ClientPutModel(self.currentClient) //sets format for put request
        var clientParams = clientPutParse.dictionaryRepresentation  //gets general parameters and authentication for put request's parameters
        var clientPrefs = self.parseExistingPreferences(clientPref: self.currentClient.preferences) //gets currentClients preferences in a array of dics to allow easy appending on a new interest
        print(clientPrefs)
        
        let newInterest: [String: Any] =
        [
            "category" : "Sports",
            "positive" : interest,
            "title" : editorTextField.text,
            "weight": Int(self.ratingView.rating),
            "timestamp" : "2019/05/23"
        ]
        clientPrefs.append(newInterest)
        clientParams["preferences"] = clientPrefs
        
        if !editorTextField.text!.isEmpty && Int(self.ratingView.rating) != 0{  //need to add refresh after the interest is added
            Alamofire.request(baseURL, method: .put, parameters: clientParams, encoding: JSONEncoding.default, headers: appUser.myHeader).responseJSON { response in
                if response.response?.statusCode == 200 {
                    print("success")
                    let alert = UIAlertController(title: "Success", message: "Interest is added, thank you", preferredStyle: UIAlertController.Style.alert)
                    self.present(alert, animated: true, completion: nil)
                    let when = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: when) { //notification dismisses after half a second, then goes back to previous view controller
                        alert.dismiss(animated: true, completion: nil)
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("damn")
                }
            }
        }
        else if editorTextField.text!.isEmpty{
            let alert = UIAlertController(title: "Error", message: "Interest needs to be filled in", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if Int(self.ratingView.rating) == 0 {
            let alert = UIAlertController(title: "Error", message: "Interest rating is not greater than zero", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func parseExistingPreferences(clientPref: [PreferenceModel]) -> [[String: Any]]{   //will go through currentClients preferences array and parse them into [[String: Any]] dictionarie. So then we can just append interests on
        var parsedPrefArrayDic = [[String: Any]]()
        for index in 0..<clientPref.count {
            parsedPrefArrayDic.append(clientPref[index].dictionaryRepresentation)
        }
        return parsedPrefArrayDic
    }
    
    func myHexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
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
}

