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
}


class LimitedTaskController: UITableViewController {
    
    var taskpost = [taskstruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let ref = Database.database().reference()
        ref.child("Task").observe(.childAdded, with: { (snapshot) in
            
            var value = snapshot.value as! [String : AnyObject]
            let taskName = value["taskName"] as! String
            let taskDistance = value["taskDistance"] as! String
            let taskDuration = value["taskDuration"] as! String
            let taskContent = value["taskContent"] as! String
            self.taskpost.insert(taskstruct(taskName:taskName, taskDistance:(taskDistance as NSString).doubleValue, taskDuration:(taskDuration as NSString).doubleValue, taskContent:taskContent), at: 0)

            self.tableView.reloadData()
        })
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return taskpost.count
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
            
            limitedtaskdetail.tasknameString =  taskpost[indexPath.row].taskName
            limitedtaskdetail.taskdurationString = "\(String(taskpost[indexPath.row].taskDuration))"
            limitedtaskdetail.taskdistanceString = "\(String(taskpost[indexPath.row].taskDistance))"
            limitedtaskdetail.taskcontentString =  taskpost[indexPath.row].taskContent
        }
        
    }
    

}
