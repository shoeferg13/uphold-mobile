//
//  suggestedComCell.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/15/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit

class suggestedComCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var headLineLabel: UILabel!
    @IBOutlet weak var headlLineView: UIView!
    @IBOutlet weak var headLineStartLabel: UILabel!
    @IBOutlet weak var headLineEndLabel: UILabel!
    @IBOutlet weak var headLineTypeLabel: UILabel!
    
    
}
