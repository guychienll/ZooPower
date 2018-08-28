//
//  RecordController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/18.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
class RecordController: UITableViewController {
    
    var days = 15
    var ref : DatabaseReference?
    var currenID = Auth.auth().currentUser?.uid
    var timer = Timer()
    var date : [String] = []
   // var location = []
    var distance : [String] = []
    var duration : [String] = []
    var pace : [String] = []
    var calories : [String] = []

    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var daysStartButton: UIButton!
    @IBOutlet weak var daysResetButton: UIButton!
    @IBOutlet weak var daysSlider: UISlider!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Database.database().reference().child("Records/\(currenID!)").queryOrderedByKey().observe(.childAdded) { (snapshot, nil) in
            let value = snapshot.value as? [String : AnyObject]
            let dateString = "\((value!["date"])!)"
            let distanceString = "\((value!["distance"])!)"
            let durationString = "\((value!["duration"])!)"
            let paceString = "\((value!["pace"])!)"
            let caloriesString = "\((value!["calorie"])!)"
            self.date.insert(dateString, at: 0)
            self.distance.insert(distanceString, at: 0)
            self.duration.insert(durationString, at: 0)
            self.pace.insert(paceString, at: 0)
            self.calories.insert(caloriesString, at: 0)
            self.tableView.reloadData()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return date.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecordCell
        cell.dateLabel?.text = date[indexPath.row]
       // cell.locationLabel?.text = location[indexPath.row]
        cell.distanceLabel?.text = distance[indexPath.row]
        cell.timeLabel?.text = duration[indexPath.row]
        cell.paceLabel?.text = pace[indexPath.row]
        cell.calorieLabel?.text = calories[indexPath.row]
        return cell
    }
    
    @IBAction func daysStartButton(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        
        daysStartButton.isHidden = true
        daysSlider.isEnabled = false
    }
    @IBAction func daysResetButton(_ sender: Any) {
        timer.invalidate()
        days = 15
        daysSlider.setValue(15 ,animated: true)
        daysLabel.text = "15" + "days"
        daysStartButton.isHidden = false
        daysSlider.isEnabled = true
        daysStartButton.isEnabled = true
    }
    @IBAction func daysSlider(_ sender: UISlider) {
        days = Int(sender.value)
        daysLabel.text = String(days) + "days"
        daysStartButton.isEnabled = true
    }
    
    
    @objc  func counter(){
        days = days - 1
        daysLabel.text = String(days) + "days"
        if days == 0{
            timer.invalidate()
            daysStartButton.isHidden = false
            daysStartButton.isEnabled = false
            daysSlider.isEnabled = true
        }
    }
    
    
   
    
}
