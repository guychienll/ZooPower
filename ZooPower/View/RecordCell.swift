//
//  RecordCell.swift
//  ZooPower
//
//  Created by User8 on 2018/8/18.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {

   
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var oceanDistanceLabel: UILabel!
    @IBOutlet weak var grassLandDistanceLabel: UILabel!
    @IBOutlet weak var rainForestDistanceLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
