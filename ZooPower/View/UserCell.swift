//
//  UserCell.swift
//  ZooPower
//
//  Created by 朱一心 on 2018/9/2.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
class UserCell: UITableViewCell{
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x:70,y:textLabel!.frame.origin.y,width:textLabel!.frame.width,height:textLabel!.frame.height)
         detailTextLabel?.frame = CGRect(x:70,y:detailTextLabel!.frame.origin.y,width:detailTextLabel!.frame.width,height:detailTextLabel!.frame.height)
        let checkbutton = UIButton(frame: CGRect(x: 290, y:470, width: 20, height: 20))
        let uncheckbutton = UIButton(frame: CGRect(x: 320, y:470, width: 20, height: 20))
        
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"icon_4")
        //才會套用下方的constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
   
 
    let timeLabel: UILabel = {
        let label = UILabel()
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    override init(style: UITableViewCell.CellStyle,reuseIdentifier: String?){
        super.init(style: .subtitle , reuseIdentifier:reuseIdentifier)
        //將圖片加入cell
        addSubview(profileImageView)
        addSubview(timeLabel)
        //constraint ,need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
         //constraint ,need x,y,width,height anchors
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

