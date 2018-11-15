//
//  LimitedTaskDetailViewController.swift
//  ZooPower
//
//  Created by stacy on 2018/10/18.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase

class LimitedTaskDetailViewController: UIViewController {
   
    @IBOutlet weak var taskname: UILabel!
    @IBOutlet weak var taskdistance: UILabel!
    @IBOutlet weak var taskduration: UILabel!
    @IBOutlet weak var taskcontent: UILabel!
    @IBOutlet weak var taskendtime: UILabel!
    @IBOutlet weak var taskstarttime: UILabel!
    @IBOutlet weak var tasklevel: UILabel!
    
    @IBOutlet weak var taskchallengebutton: UIButton!
    
    var currenID = Auth.auth().currentUser?.uid
    var timer = Timer()
    var taskIdnum: DatabaseReference!
    var tasknameString: String!
    var taskdurationString: String!
    var taskdistanceString: String!
    var taskcontentString: String!
    var taskStartTimeString: String!
    var taskEndTimeString: String!
    var taskStartTimeDouble: Double!
    var taskEndTimeDouble: Double!
    
    var onSavetasktimer : ((_ data: Int) -> ())?
    var onSavetaskendtime : ((_ data: Int) -> ())?
    var onSavetaskduration : ((_ data: Double) -> ())?
    var onSavetaskdistance : ((_ data: Double) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = NSDate().timeIntervalSince1970 
        print("//now time://")
        print(Int(taskStartTimeDouble))
        print(Int(date))
        print(Int(taskEndTimeDouble))
        print(taskIdnum)
        
        taskname.text = tasknameString
        taskduration.text = "限制時間："+taskdurationString+" 分鐘"
        taskdistance.text = "需達成距離："+taskdistanceString+" 公里"
        taskcontent.text = "任務內容："+taskcontentString

        taskstarttime.text = taskStartTimeString
        taskendtime.text = taskEndTimeString
        
        
        //task start
        if (Int(date) >= Int(taskStartTimeDouble) && Int(date) < Int(taskEndTimeDouble)){
            if(taskchallengebutton.isSelected == false){
            taskchallengebutton.isHidden = false
            taskchallengebutton.isEnabled = true
            }
            else{
                self.taskchallengebutton.isHidden = true
                self.tasklevel.text = "任務進行中"
                self.tasklevel.backgroundColor = UIColor.lightGray
            }
        }
        //task has been closed
        else if(Int(date) >= Int(taskEndTimeDouble)){
            taskchallengebutton.isHidden = true
            tasklevel.text = "任務已結束"
            tasklevel.backgroundColor = UIColor.lightGray
            timer.invalidate()
        }
    }
    
        @IBAction func challenge(_ sender: Any){
            //取得按下任務件隻時間戳記
            let taskdate = Int(NSDate().timeIntervalSince1970)
            onSavetasktimer?(taskdate)
            onSavetaskdistance?(((self.taskdistanceString as NSString).doubleValue)*1000)
            onSavetaskduration?(((self.taskdurationString as NSString).doubleValue)*60)
            onSavetaskendtime?(Int(taskEndTimeDouble))
            
            self.taskchallengebutton.isHidden = true
            self.tasklevel.text = "任務進行中"
            self.tasklevel.backgroundColor = UIColor.lightGray
            
    }
    
    @IBAction func closeButton(_sender: Any){
        dismiss(animated: true, completion: nil)
    }
    //END
}

