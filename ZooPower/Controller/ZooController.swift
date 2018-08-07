//
//  ZooController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/5.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class ZooController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //隱藏navigationbar（透明化）
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    //動物園地區頁面導向
    @IBAction func oceanZoneButton(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let zooMainController = sb.instantiateViewController(withIdentifier: "ZooMainController") as? ZooMainController
        zooMainController?.cellFlag = 0
        self.show(zooMainController!, sender: nil)
    }
    @IBAction func grasslandZoneButton(_ sender: Any) {let sb = UIStoryboard(name: "Main", bundle: nil)
        let zooMainController = sb.instantiateViewController(withIdentifier: "ZooMainController") as? ZooMainController
        zooMainController?.cellFlag = 1
        self.show(zooMainController!, sender: nil)
    }
    @IBAction func rainforestZoneButton(_ sender: Any) {let sb = UIStoryboard(name: "Main", bundle: nil)
        let zooMainController = sb.instantiateViewController(withIdentifier: "ZooMainController") as? ZooMainController
        zooMainController?.cellFlag = 2
        self.show(zooMainController!, sender: nil)
    }
    @IBAction func specialZoneButton(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let zooMainController = sb.instantiateViewController(withIdentifier: "ZooMainController") as? ZooMainController
        zooMainController?.cellFlag = 3
        self.show(zooMainController!, sender: nil)
    }

}
