//
//  InterestEditorClientCell.swift
//  UpHoldMobile
//
//  Created by Shannon Ferguson on 7/26/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit


class InterestEditorClientCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBOutlet weak var clientProfilePic: UIImageView!
    
    @IBOutlet weak var clientName: UILabel!
    
    
}
