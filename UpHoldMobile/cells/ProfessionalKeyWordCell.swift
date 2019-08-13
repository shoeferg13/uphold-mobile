//
//  ProfessionalKeyWordCell.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/16/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit

class ProfessionalKeyWordCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var keywordTitleLabel: UILabel!
    var currHeight = 0
    
    func display(clientKeywords : [String]) {
        for index in 0..<clientKeywords.count {
            let labelNum = UILabel()
            let element = clientKeywords[index]
            labelNum.lineBreakMode = .byWordWrapping
            labelNum.numberOfLines = 0
            labelNum.text = "   " + element
            labelNum.textAlignment = .left
            labelNum.font = UIFont(name: "HelveticaNeue-Light", size: 15)
            labelNum.textColor = UIColor(red: 0.19, green: 0.24, blue: 0.33, alpha: 1)
            let smallWidth = labelNum.text!.count * 15
            let normalWidth = labelNum.text!.count * 10
            labelNum.frame = CGRect(x: 20, y: currHeight, width: normalWidth, height: 33)
            labelNum.layer.borderColor = UIColor(red: 0.19, green: 0.24, blue: 0.33, alpha: 1).cgColor
            labelNum.layer.borderWidth = 1
            self.contentView.addSubview(labelNum)
            currHeight += 45
        }
    }
}
