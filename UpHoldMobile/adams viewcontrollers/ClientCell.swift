//
//  ClientCell.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 6/28/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit

class ClientCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        clientImage.clipsToBounds = true
        
//        let companyColor = hexStringToUIColor(hex: "844865")
//        clientCompanyLabel.textColor = companyColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var clientImage: UIImageView!
    @IBOutlet weak var clientCompanyLabel: UILabel!
    
    func hexStringToUIColor (hex:String) -> UIColor {   //takes a hex number and converts it to the string equiv of a color
        let cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
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
