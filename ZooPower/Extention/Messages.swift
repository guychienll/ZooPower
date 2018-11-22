//
//  Message.swift
//  ZooPower
//
//  Created by 朱一心 on 2018/8/31.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
class Messages: NSObject {
    var fromId :String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    func chatPartnerId() -> String{
        //如果我傳給簡立 在簡立那邊不能顯示toid
        let chatPartnerId: String?
        if fromId == Auth.auth().currentUser?.uid{
            return toId!
        } else{
            return fromId!
            
        }
        
    }
   
}
