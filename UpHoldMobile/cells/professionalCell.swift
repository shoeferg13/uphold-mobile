//
//  professionalCell.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/12/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit

class professionalCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var divisionLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var PhoneLabel: UILabel!
    
}
