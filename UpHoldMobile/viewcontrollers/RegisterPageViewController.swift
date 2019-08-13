//
//  RegisterPageViewController.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/19/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

class RegisterPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBAction func registerOnPress(_ sender: Any) {
        let myHeader = ["Content-Type" : "application/json"]
        var firstName = firstNameTextField.text ?? ""
        var lastName = lastNameTextField.text ?? ""
        
        let myParameters: Parameters = [
            "username" : usernameTextField.text,
            "password" : passwordTextField.text,
            "first_name" : firstNameTextField.text,
            "last_name" : lastNameTextField.text,
            "email" : emailTextField.text,
            "mobile_number" : phoneTextField.text
        ]
        
        Alamofire.request("http://dev-uphold-backend.labs.fulcrumgt.com/user/userdata/", method: .post, parameters: myParameters, encoding: JSONEncoding.default, headers: myHeader).responseJSON { response in
            debugPrint(response.result)
            let statusCode = response.response?.statusCode
            if statusCode == 200 {
                print("CONGRATS")
                self.performSegue(withIdentifier: "registerToLogin", sender: nil)
            }
            else if statusCode! == 400 {
                print("Lawyer already exists")
                let alert = UIAlertController(title: "Error", message: "Please fill out entire form", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Server Error")
                let alert = UIAlertController(title: "Error", message: "Server is down", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
