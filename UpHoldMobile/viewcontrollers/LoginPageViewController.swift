//
//  LoginPageViewController.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/19/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit
import Alamofire

class LoginPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
 

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func loginOnPress(_ sender: Any) {
        let myLogin: Parameters = ["username" : usernameTextField.text, "password" : passwordTextField.text]
        let myHeader = ["Content-Type" : "application/json"]
        Alamofire.request("http://dev-uphold-backend.labs.fulcrumgt.com/user/login/", method: .post, parameters: myLogin, encoding: JSONEncoding.default, headers: myHeader).responseJSON { response in
            let statusCode = response.response?.statusCode
            if statusCode == 200 {
                let json = try? JSONSerialization.jsonObject(with: response.data!, options: [])
                print(json)
                let profile = json as! [String: Any]
                appUser.appUserUsername = self.usernameTextField.text
                let clientToken = profile["token"] as! String
                var authen = "Token "
                authen.append(clientToken)
                appUser.appUserToken = authen
                
                let inProfile = profile["profile"] as! [String:Any]
                appUser.appUserPhone = inProfile["mobile_number"] as! String
                
                let user = inProfile["user"] as! [String: Any]
                appUser.appUserEmail = user["email"] as! String
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else if statusCode! <= 500 {
                print("Username or password is incorrect")
                let alert = UIAlertController(title: "Error", message: "Your username or password is incorrect", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.usernameTextField.text = ""
                self.passwordTextField.text = ""
            } else {
                print("Server Error")
                let alert = UIAlertController(title: "Error", message: "Server is down", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.usernameTextField.text = ""
                self.passwordTextField.text = ""
            }
        }
    }
    
}
