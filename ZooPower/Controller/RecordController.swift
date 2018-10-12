//
//  RecordController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/18.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation


class RecordController: UITableViewController {
    
    var aimedSetting : UInt?
    var days = 15
    var aimedDistance = 100.0
    var ref : DatabaseReference?
    var currenID = Auth.auth().currentUser?.uid
    var timer = Timer()
    var date : [String] = []
    var distance : [String] = []
    var oceanDistance : [String] = []
    var grassLandDistance : [String] = []
    var rainForestDistance : [String] = []
    var duration : [String] = []
    var pace : [String] = []
    var calories : [String] = []
    //目標天數元件
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var daysStartButton: UIButton!
    @IBOutlet weak var daysResetButton: UIButton!
    @IBOutlet weak var daysSlider: UISlider!
    //目標距離元件
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceStartButton: UIButton!
    @IBOutlet weak var distanceResetButton: UIButton!
    @IBOutlet weak var distanceSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //隱藏navigationbar（透明化）
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.isNavigationBarHidden = true
        Database.database().reference().child("Records/\(currenID!)").queryOrderedByKey().observe(.childAdded) { (snapshot, nil) in
            let value = snapshot.value as? [String : AnyObject]
            //時間戳記格式化
            let x = value!["date"]! as! Double / 1000
            let date = NSDate(timeIntervalSince1970: TimeInterval(x))
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: date as Date)
            
            let distanceString = Double(round((value!["distance"] as! Double / 1000) * 1000) / 1000)
            let oceanDistanceString = Double(round((value!["oceanDistance"] as! Double / 1000) * 1000) / 1000)
            let grassLandDistanceString = Double(round((value!["grassLandDistance"] as! Double / 1000) * 1000) / 1000)
            let rainForestDistanceString = Double(round((value!["rainForestDistance"] as! Double / 1000) * 1000) / 1000)

            let durationString = FormatDisplay.time(value!["duration"] as! Int)
            let paceString = Double(round((((value!["duration"] as! Double) / 60) / distanceString) * 100) / 100)
            let caloriesString = Double(round((value!["calorie"] as! Double) * 100) / 100)
            self.date.insert(dateString, at: 0)
            self.distance.insert(String(distanceString), at: 0)
            self.oceanDistance.insert(String(oceanDistanceString), at: 0)
            self.grassLandDistance.insert(String(grassLandDistanceString), at: 0)
            self.rainForestDistance.insert(String(rainForestDistanceString), at: 0)
            self.duration.insert(durationString, at: 0)
            self.pace.insert(String(paceString), at: 0)
            self.calories.insert(String(caloriesString), at: 0)
            
            
            
            
            
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
        cell.oceanDistanceLabel.text = oceanDistance[indexPath.row]
        cell.grassLandDistanceLabel.text = grassLandDistance[indexPath.row]
        cell.rainForestDistanceLabel.text = rainForestDistance[indexPath.row]
        cell.timeLabel?.text = duration[indexPath.row]
        cell.paceLabel?.text = pace[indexPath.row]
        cell.calorieLabel?.text = calories[indexPath.row]
        return cell
    }
    
    @IBAction func startButton(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        
        let currrntTimestamp = NSDate().timeIntervalSince1970
        aimedSetting = Database.database().reference().child("Records/\(currenID!)").observe(.childAdded) { (snapshot) in
            let values = snapshot.value as! [String : AnyObject]
            let distance = (values["distance"] as! Double) / 1000
            let recordsTimestamp = values["date"] as! Double / 1000
            if recordsTimestamp > currrntTimestamp {
                self.aimedDistance -= distance
                self.distanceLabel.text = "\(Double(round(self.aimedDistance * 100) / 100))"
                if self.aimedDistance <= 0 {
                    self.distanceLabel.text = "0.0km"
                    self.distanceStartButton.isHidden = false
                    self.distanceStartButton.isEnabled = false
                    self.distanceSlider.isEnabled = true
                }
            }
        }
        distanceSlider.isEnabled = false
        daysStartButton.isHidden = true
        daysSlider.isEnabled = false
    }
    @IBAction func resetButton(_ sender: Any) {
        timer.invalidate()
        days = 1
        daysSlider.setValue(1 ,animated: true)
        daysLabel.text = "0"
        
        aimedDistance = 1.0
        distanceSlider.setValue(1.0 ,animated: true)
        distanceLabel.text = "0.0"
        distanceSlider.isEnabled = true
        Database.database().reference().child("Records/\(currenID!)").removeObserver(withHandle: aimedSetting!)
        
        daysStartButton.isHidden = false
        daysSlider.isEnabled = true
        daysStartButton.isEnabled = true
    }
    @IBAction func daysSlider(_ sender: UISlider) {
        days = Int(sender.value)
        daysLabel.text = String(days)
        daysStartButton.isEnabled = true
    }
    
    
    @objc  func counter(){
        days = days - 1
        daysLabel.text = String(days)
        if days == 0{
            timer.invalidate()
            daysStartButton.isHidden = false
            daysStartButton.isEnabled = false
            daysSlider.isEnabled = true
        }
    }
    

    @IBAction func distanceSlider(_ sender: UISlider) {
        aimedDistance = (Double(sender.value).rounded() / 1000) * 1000
        distanceLabel.text = String(aimedDistance)
        daysStartButton.isEnabled = true

    }
    
   
    
}

