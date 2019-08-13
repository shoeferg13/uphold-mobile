//
//  personalCell.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/12/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit
import Alamofire

class personalCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() -> Void {
        super.prepareForReuse()
        for views in self.contentView.subviews {
            if views is UILabel && views.tag != -1{ //removes all labels made programatically except the personalTitleLabel
                views.removeFromSuperview()
            }
        }
    }

    var delegate: UIViewController?
    @IBOutlet weak var personalTitleLabel: UILabel! {
        didSet {
            self.personalTitleLabel.tag = -1
        }
    }
    var currHeight = 0
    var currentClient: ClientModel! = nil
    var myRowHeight: Int!
    
    func display(tempCurr: [String], weights: [String], myIndexPath: Int, likesCount: Int) {
        let newHeight:Double = Double(currHeight)
        for index in 0..<tempCurr.count {
            //print("tempCurr count: \(tempCurr.count)")
            currHeight += 45
            let element = tempCurr[index]
            let labelNum = UILabel()
            labelNum.isUserInteractionEnabled = true
            if myIndexPath == 1 || myIndexPath == 2 {
                labelNum.text = "   " + element + "   " + weights[index]
                let labelEx = UIButton(type: .custom)   //button that will be used to delete interest if user chooses to do so
                labelEx.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                labelEx.tag = index
                //print("index \(index)")
                if myIndexPath == 1 {
                    labelEx.tag = index
                }
                else if myIndexPath == 2 {
                    labelEx.tag = likesCount + index
                }
                labelEx.setImage(UIImage(named: "remove-symbol"), for: .normal) //sets the button image to an "X"
                labelEx.frame = CGRect(x: 150, y: Int(newHeight), width: 10, height: 10)
                labelNum.addSubview(labelEx)    //adds the button to the label
            } else {
                labelNum.text = "   " + element
            }
            let normalWidth = labelNum.text!.count * 10
            labelNum.textAlignment = .left
            labelNum.frame = CGRect(x: 20, y: currHeight, width: 177, height: 33)
            labelNum.layer.borderColor = UIColor(red: 0.19, green: 0.24, blue: 0.33, alpha: 1).cgColor
            labelNum.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            labelNum.textColor = UIColor(red: 0.19, green: 0.24, blue: 0.33, alpha: 1)
            labelNum.layer.borderWidth = 1
            contentView.addSubview(labelNum)
        }
        myRowHeight = currHeight
        
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        print("pressed")
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this interest?", preferredStyle: UIAlertController.Style.alert)
        let delete = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) { (_) in
            self.deleteInterest(index: sender.tag)  //sends over what index the interest/dislike is
        }
        let cancel = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        //self.present(alert, animated: true, completion: nil)
        //UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        delegate!.present(alert, animated: true, completion: nil)
    }
    
    
    func deleteInterest(index: Int) {
        let baseURL = "https://dev-uphold-backend.labs.fulcrumgt.com/user/clients/" + String(self.currentClient.id) + "/"
        var clientPutParse = ClientPutModel(self.currentClient) //sets format for put request
        var clientParams = clientPutParse.dictionaryRepresentation  //gets general parameters and authentication for put request's parameters
        var clientPrefs = self.parseExistingPreferences(clientPref: self.currentClient.preferences) //gets currentClients preferences in a array of dics to allow easy appending on a new interest
        //print(index)
        clientPrefs.remove(at: index)   //removes this interets from the array that will send to change the client profile
        
        clientParams["preferences"] = clientPrefs
        Alamofire.request(baseURL, method: .put, parameters: clientParams, encoding: JSONEncoding.default, headers: appUser.myHeader).responseJSON {response in
            if response.response?.statusCode == 200 {
                print("Success")
                //_ = self.navigationController?.popViewController(animated: true)
                _ = self.delegate?.navigationController?.popViewController(animated: true)
            } else {
                print(response.error)
            }
        }
    }
    
    func parseExistingPreferences(clientPref: [PreferenceModel]) -> [[String: Any]]{   //will go through currentClients preferences array and parse them into [[String: Any]] dictionarie. So then we can just append interests on
        var parsedPrefArrayDic = [[String: Any]]()
        var dislikesIndexes = [Int]()
        for index in 0..<clientPref.count { //front loads the array with intersts
            let positiveChecker = clientPref[index].dictionaryRepresentation
            let positiveBool = positiveChecker["positive"] as! Bool
            if positiveBool {
                parsedPrefArrayDic.append(clientPref[index].dictionaryRepresentation)
            } else {
                dislikesIndexes.append(index)
            }
        }
        
        for index in 0..<dislikesIndexes.count {    //backloads the array with dislikes
            parsedPrefArrayDic.append(clientPref[dislikesIndexes[index]].dictionaryRepresentation)
        }
        print(parsedPrefArrayDic.count)
        return parsedPrefArrayDic
    }
    
}
