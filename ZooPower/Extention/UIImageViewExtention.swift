//
//  File.swift
//  ZooPower
//
//  Created by User8 on 2018/8/4.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

extension UIImageView{
    func load(url: URL) -> () {
        DispatchQueue.global().async {
            [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
