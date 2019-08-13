//
//  legalCell.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/12/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit

class legalCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var startLabel: UILabel?
    @IBOutlet weak var endLabel: UILabel?
    @IBOutlet weak var typeLabel: UILabel?
    @IBOutlet weak var partnerLabel: UILabel?

}
