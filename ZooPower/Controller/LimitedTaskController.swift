//
//  LimitedTaskController.swift
//  ZooPower
//
//  Created by ZooPower on 2018/10/15.
//  Copyright © 2018 com.fjuim. All rights reserved.
//

import UIKit

class LimitedTaskController: UITableViewController {

    var task = [["taskName" : "獨角獸任務" , "taskDistance" : 10.0 , "taskTime" : 60] ,
                ["taskName" : "渡渡鳥任務" , "taskDistance" : 10.0 , "taskTime" : 60],
                ["taskName" : "恐龍任務" , "taskDistance" : 10.0 , "taskTime" : 60],
                ["taskName" : "鳳凰任務" , "taskDistance" : 10.0 , "taskTime" : 60],
                ["taskName" : "玄武任務" , "taskDistance" : 10.0 , "taskTime" : 60],
                ["taskName" : "木須龍任務" , "taskDistance" : 10.0 , "taskTime" : 60],
                ["taskName" : "白虎任務" , "taskDistance" : 10.0 , "taskTime" : 60],
                ["taskName" : "國王企鵝任務" , "taskDistance" : 10.0 , "taskTime" : 60],
                ["taskName" : "青龍任務" , "taskDistance" : 10.0 , "taskTime" : 60]]
    
    var taskName = [String]()
    var taskDistance = [Double]()
    var taskTime = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0...8 {
            self.taskName.append(self.task[i]["taskName"] as! String)
            self.taskDistance.append(self.task[i]["taskDistance"] as! Double)
            self.taskTime.append(self.task[i]["taskTime"] as! Int)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 9
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LimitedTaskCell
        cell.taskNameLabel.text = taskName[indexPath.row]
        cell.taskDistance.text = "\(taskDistance[indexPath.row])"
        cell.taskTime.text = "\(taskTime[indexPath.row])"
        return cell 
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
