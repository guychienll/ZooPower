//
//  RecordCell.swift
//  ZooPower
//
//  Created by User8 on 2018/8/18.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {

    @IBOutlet weak var backgroundCardView: UIView!{
        didSet{
            backgroundCardView.backgroundColor = UIColor(red: 197/255, green: 231/255, blue:255/255, alpha: 0.5)
            contentView.backgroundColor = UIColor(red: 247/255, green: 250/255, blue:255/255, alpha: 0.5)
            backgroundCardView.layer.cornerRadius = 5.0
            backgroundCardView.layer.masksToBounds = false
            backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
            backgroundCardView.layer.shadowOpacity = 2
        }
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
