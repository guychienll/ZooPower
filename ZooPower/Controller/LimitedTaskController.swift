//
//  LimitedTaskController.swift
//  ZooPower
//
//  Created by ZooPower on 2018/10/15.
//  Copyright © 2018 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

struct taskstruct{
    let taskName : String!
    let taskDistance: Double!
    let taskDuration : Double!
    let taskContent : String!
    let taskStartTimeString : String!
    let taskEndTimeString : String!
    let taskStartTimeDouble: Double!
    let taskEndTimeDouble: Double!
    let taskId: String!
}


class LimitedTaskController: UITableViewController {
    
    var taskpost = [taskstruct]()
    var taskdate = 0
    var taskendtime = 0
    var taskduration = 0.0
    var taskdistance = 0.0
    var taskId = ""
    var onSavetasktimer2 : ((_ data: Int) -> ())?
    var onSavetaskendtime2 : ((_ data: Int) -> ())?
    var onSavetaskduration2 : ((_ data: Double) -> ())?
    var onSavetaskdistance2 : ((_ data: Double) -> ())?
    var onSavetaskId2 : ((_ data: String) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let ref = Database.database().reference()
        ref.child("Task").observe(.childAdded, with: { (snapshot) in
            
            var value = snapshot.value as! [String : AnyObject]
            let taskId = snapshot.key as! String
            let taskName = value["taskName"] as! String
            let taskDistance = value["taskDistance"] as! String
            let taskDuration = value["taskDuration"] as! String
            let taskContent = value["taskContent"] as! String
            if let starttime = value["startTime"] {
                let starttimecheck =  (starttime as! Double) / 1000
                let startdate = NSDate(timeIntervalSince1970: TimeInterval(starttimecheck))
                let startformatter = DateFormatter()
                startformatter.dateStyle = .medium
                let taskStartTime = startformatter.string(from: startdate as Date)
                
                let endtime = value["endTime"]! as! Double / 1000
                let enddate = NSDate(timeIntervalSince1970: TimeInterval(endtime))
                let endformatter = DateFormatter()
                endformatter.dateStyle = .medium
                let taskEndTime = endformatter.string(from: enddate as Date)
                
                self.taskpost.insert(taskstruct(taskName:taskName, taskDistance:(taskDistance as NSString).doubleValue, taskDuration:(taskDuration as NSString).doubleValue, taskContent: taskContent, taskStartTimeString: taskStartTime, taskEndTimeString: taskEndTime, taskStartTimeDouble: starttimecheck, taskEndTimeDouble: endtime, taskId: taskId), at: 0)
                
                self.tableView.reloadData()

            }else{
                
            }
                    })
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return taskpost.count
    }
    
    func onSavetasktimer(_ data: Int) -> (){
         taskdate = data
        onSavetasktimer2?(taskdate)
    }
    func onSavetaskendtime(_ data: Int) -> (){
        taskendtime = data
        onSavetaskendtime2?(taskendtime)
    }
    func onSavetaskduration(_ data: Double) -> (){
        taskduration = data
        onSavetaskduration2?(taskduration)
    }
    func onSavetaskdistance(_ data: Double) -> (){
        taskdistance = data
        onSavetaskdistance2?(taskdistance)
    }
    func onSavetaskId(_ data: String) -> (){
        taskId = data
        onSavetaskId2?(taskId)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "LimitedtaskCell")
        
        let taskname = cell?.viewWithTag(1) as! UILabel
        taskname.text = taskpost[indexPath.row].taskName
        return cell!
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // indexfordetail = indexPath.row
        self.performSegue(withIdentifier: "limitedtasksegue", sender: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "limitedtasksegue",
            let limitedtaskdetail = segue.destination as? LimitedTaskDetailViewController,
            let indexPath = self.tableView.indexPathForSelectedRow{
            limitedtaskdetail.taskId = taskpost[indexPath.row].taskId
            limitedtaskdetail.tasknameString =  taskpost[indexPath.row].taskName
            limitedtaskdetail.taskdurationString = "\(String(taskpost[indexPath.row].taskDuration))"
            limitedtaskdetail.taskdistanceString = "\(String(taskpost[indexPath.row].taskDistance))"
            limitedtaskdetail.taskcontentString =  taskpost[indexPath.row].taskContent
            limitedtaskdetail.taskStartTimeString = taskpost[indexPath.row].taskStartTimeString
            limitedtaskdetail.taskEndTimeString
                = taskpost[indexPath.row].taskEndTimeString
            limitedtaskdetail.taskStartTimeDouble  = taskpost[indexPath.row].taskStartTimeDouble
            limitedtaskdetail.taskEndTimeDouble = taskpost[indexPath.row].taskEndTimeDouble
            
            limitedtaskdetail.onSavetasktimer = onSavetasktimer
            limitedtaskdetail.onSavetaskendtime = onSavetaskendtime
            limitedtaskdetail.onSavetaskduration = onSavetaskduration
            limitedtaskdetail.onSavetaskdistance = onSavetaskdistance
            limitedtaskdetail.onSavetaskId = onSavetaskId
        }
        
    }
    

}
