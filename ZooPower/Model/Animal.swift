//
//  Animal.swift
//  ZooPower
//
//  Created by User8 on 2018/8/4.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import Foundation

class Animal {
    var name : String
    var image : String
    var location :String
    var info :String
    
    init(name : String , image : String , location : String , info : String) {
        self.name = name
        self.image = image
        self.location = location
        self.info = info
    }
    
    convenience init(){
        self.init(name: "", image: "", location: "", info: "")
    }
}
