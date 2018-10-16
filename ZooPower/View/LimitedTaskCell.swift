//
//  LimitedTaskCell.swift
//  ZooPower
//
//  Created by ZooPower on 2018/10/15.
//  Copyright © 2018 com.fjuim. All rights reserved.
//

import UIKit
import Firebase

class LimitedTaskCell: UITableViewCell {

    @IBOutlet weak var taskAcceptButton: UIButton!{
        didSet{
            taskAcceptButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskDistance: UILabel!
    @IBOutlet weak var taskTime: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func taskAcceptButton(_ sender: Any) {
        switch taskNameLabel.text {
        case "獨角獸任務":
            print(1)
            taskAcceptButton.isHidden = true
        case "渡渡鳥任務":
            print(2)
            taskAcceptButton.isHidden = true
        case "恐龍任務":
            print(3)
            taskAcceptButton.isHidden = true
        case "鳳凰任務":
            print(4)
            taskAcceptButton.isHidden = true
        case "玄武任務":
            print(5)
            taskAcceptButton.isHidden = true
        case "木須龍任務":
            print(6)
            taskAcceptButton.isHidden = true
        case "白虎任務":
            print(7)
            taskAcceptButton.isHidden = true
        case "國王企鵝任務":
            print(8)
            taskAcceptButton.isHidden = true
        case "青龍任務":
            print(9)
            taskAcceptButton.isHidden = true
        default:
            print("something is Error")
        }
        
    }

     
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
