//
//  LimitedTaskDetailViewController.swift
//  ZooPower
//
//  Created by stacy on 2018/10/18.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class LimitedTaskDetailViewController: UIViewController {
   
    @IBOutlet weak var taskname: UILabel!
    @IBOutlet weak var taskdistance: UILabel!
    @IBOutlet weak var taskduration: UILabel!
    @IBOutlet weak var taskcontent: UILabel!
    
    var tasknameString: String!
    var taskdurationString: String!
    var taskdistanceString: String!
    var taskcontentString: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskname.text = tasknameString
        taskduration.text = "限制時間："+taskdurationString+" 分鐘"
        taskdistance.text = "需達成距離："+taskdistanceString+" 公里"
        taskcontent.text = "任務內容："+taskcontentString
    }
    
    @IBAction func closeButton(_sender: Any){
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
