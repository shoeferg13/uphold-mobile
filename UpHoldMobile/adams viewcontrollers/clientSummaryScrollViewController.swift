//
//  clientSummaryScrollViewController.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/11/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit
import Photos
import Alamofire

class clientSummaryScrollViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var chosenImage: UIImage!
    let imagePicker = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        let parentVC = ClientListViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientNameLabel.text = clientName
        clientCompanyLabel.text = clientCompany
        clientPicImageView.image = clientPic
        actualClientCompanyLabel.text = clientActualCompany
        ageofrelationshipLabel.text = ageofrelation
        legalButton.backgroundColor = UIColor.white
        professionalButton.backgroundColor = UIColor.white
        personalButton.backgroundColor = UIColor.white
        imagePicker.delegate = self
        self.title = clientName
    }
    var clientName: String = ""
    var clientPic: UIImage!
    var clientCompany: String = ""
    var clientActualCompany: String = ""
    var clientDepartment: String = ""
    var ageofrelation: String = ""
    var clientDictionary = [Int: [String]]()
    var clientMatters = [MatterModel]()
    var segIndex: Int = 3
    @IBOutlet weak var clientPicImageView: UIImageView!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var clientCompanyLabel: UILabel!
    @IBOutlet weak var actualClientCompanyLabel: UILabel!
    weak var childSummaryTableViewController: summaryTableViewController!
    weak var clientTrendsVC: TrendsViewController!
    var clientsTrends = [TrendsModel]()
    var currentClient: ClientModel!
    var names: [String] = ["Legal","Professional","Personal"]
    
    @IBOutlet weak var numMattersLabel: UILabel! {
        didSet {
            self.numMattersLabel.text = String(clientMatters.count)
        }
    }
    @IBOutlet weak var ageofrelationshipLabel: UILabel!
    
    
    @IBOutlet weak var legalButton: UIButton!
    @IBAction func legalButtonOnPress(_ sender: Any) {
        if legalButton.backgroundColor == UIColor.white {
            legalButton.backgroundColor = UIColor(red: 0.88, green: 0.76, blue: 0.84, alpha: 0.38)
            personalButton.backgroundColor = UIColor.white
            professionalButton.backgroundColor = UIColor.white
            childSummaryTableViewController.typeIndex = 0
            childSummaryTableViewController.tableView.separatorStyle = .singleLine
            childSummaryTableViewController.tableView.reloadData()
        } else {
            legalButton.backgroundColor = UIColor.white
            childSummaryTableViewController.typeIndex = 3
            childSummaryTableViewController.tableView.separatorStyle = .none
            childSummaryTableViewController.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var professionalButton: UIButton!
    @IBAction func professionalButtonOnPress(_ sender: Any) {
        if professionalButton.backgroundColor == UIColor.white {
            professionalButton.backgroundColor = UIColor(red: 0.88, green: 0.76, blue: 0.84, alpha: 0.38)
            legalButton.backgroundColor = UIColor.white
            personalButton.backgroundColor = UIColor.white
            childSummaryTableViewController.typeIndex = 1
            childSummaryTableViewController.tableView.separatorStyle = .singleLine
            childSummaryTableViewController.tableView.reloadData()
        } else {
            professionalButton.backgroundColor = UIColor.white
            childSummaryTableViewController.typeIndex = 3
            childSummaryTableViewController.tableView.separatorStyle = .none
            childSummaryTableViewController.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var personalButton: UIButton!
    @IBAction func personalButtonOnPress(_ sender: Any) {
        if personalButton.backgroundColor == UIColor.white {
            personalButton.backgroundColor = UIColor(red: 0.88, green: 0.76, blue: 0.84, alpha: 0.38)
            legalButton.backgroundColor = UIColor.white
            professionalButton.backgroundColor = UIColor.white
            childSummaryTableViewController.typeIndex = 2
            childSummaryTableViewController.tableView.separatorStyle = .singleLine
            childSummaryTableViewController.tableView.reloadData()
        } else {
            personalButton.backgroundColor = UIColor.white
            childSummaryTableViewController.typeIndex = 3
            childSummaryTableViewController.tableView.separatorStyle = .none
            childSummaryTableViewController.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "childSegue" {
            let childViewController = segue.destination as! summaryTableViewController
            childViewController.matters = clientMatters
            childViewController.typeIndex = segIndex
            childViewController.clientDics = clientDictionary
            childViewController.types = names
            childViewController.clientsName = clientName
            childViewController.clientsComapny = clientActualCompany
            childViewController.clientsPostion = clientCompany
            childViewController.clientsDepartment = clientDepartment
            childViewController.clientsPhone = self.currentClient.phone_number!
            childViewController.clientsEmail = self.currentClient.email!
            childViewController.currentClient = self.currentClient
            childViewController.tableView.separatorStyle = .none
            childSummaryTableViewController = childViewController
        } else if segue.identifier == "clientToTrends" {
            let childViewController = segue.destination as! TrendsViewController
            childViewController.clientTrends = self.clientsTrends
            clientTrendsVC = childViewController
        } else if segue.identifier == "clientToInterest" {
            let childViewController = segue.destination as! InterestEditorViewController
            childViewController.currentClient = self.currentClient
        } else if segue.identifier == "clientToSuggest" {
            let childViewController = segue.destination as! SuggestedCommunication
            childViewController.currentClient = self.currentClient
            childViewController.allTrends = self.clientsTrends
        }
    }
    

    @IBAction func addPictureButton(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            clientPicImageView.contentMode = .scaleAspectFill
            clientPicImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

    
    
}
