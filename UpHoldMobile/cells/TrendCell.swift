//
//  TrendCell.swift
//  UpHoldMobile
//
//  Created by Adam Ding on 7/23/19.
//  Copyright © 2019 Shannon Ferguson. All rights reserved.
//

import UIKit


class TrendCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var clientTrends = [TrendsModel]()
    var clientIndex: Int!
    @IBOutlet weak var trendImage: UIImageView!
    @IBOutlet weak var trendTopicLabel: UILabel!    //label for what topic the trend is on
    @IBOutlet weak var trendDateLabel: UILabel! //trend used for keeping track of when the trend was pulled from the backend
    @IBAction func trendURLOnPress(_ sender: Any) { //functions open url if there is one for the trend cell
        //guard let url = URL(string: clientTrends[clientIndex].url) else {return}
        //UIApplication.shared.open(url)
    }

    

}
