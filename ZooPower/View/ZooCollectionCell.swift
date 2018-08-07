//
//  ZooCollectionCell.swift
//  ZooPower
//
//  Created by User8 on 2018/8/6.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class ZooCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var animalImage: UIImageView!{
        didSet{
            animalImage.layer.borderWidth = 1
            animalImage.layer.borderColor = UIColor.white.cgColor
            animalImage.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var animalNameLabel: UILabel!
}
