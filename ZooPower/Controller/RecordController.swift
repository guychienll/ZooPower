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
    
    var run : Run!
    
    var days = 15
    var aimedDistance = 100.0
    var ref : DatabaseReference?
    var currenID = Auth.auth().currentUser?.uid
    var timer = Timer()
    var date : [String] = []
   // var location = []
    var distance : [String] = []
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
    
    @IBOutlet weak var mapView: MKMapView!
    
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
            
            let durationString = FormatDisplay.time(value!["duration"] as! Int)
            let paceString = Double(round((((value!["duration"] as! Double) / 60) / distanceString) * 100) / 100)
            let caloriesString = Double(round((value!["calorie"] as! Double) * 100) / 100)
            self.date.insert(dateString, at: 0)
            self.distance.insert(String(distanceString), at: 0)
            self.duration.insert(durationString, at: 0)
            self.pace.insert(String(paceString), at: 0)
            self.calories.insert(String(caloriesString), at: 0)
            self.mapView.delegate = self
            self.mapView.isZoomEnabled = false
            //self.mapView.isScrollEnabled = false
            //self.mapView.isPitchEnabled = false
            //self.mapView.isRotateEnabled = false
            if self.run != nil {
                self.loadMap()
            }else{
                
            }
            
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
    
    @IBAction func startButton(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        
        let currrntTimestamp = NSDate().timeIntervalSince1970
        Database.database().reference().child("Records/\(currenID!)").observe(.childAdded) { (snapshot) in
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
        Database.database().reference().child("Records/\(currenID!)").removeAllObservers()
        
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
    
    private func mapRegion() -> MKCoordinateRegion? {
        guard
            let locations = run.locations,
            locations.count > 0
            else {
                return nil
        }
        
        let latitudes = locations.map { location -> Double in
            let location = location as! Location
            return location.latitude
        }
        
        let longitudes = locations.map { location -> Double in
            let location = location as! Location
            return location.longitude
        }
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                    longitudeDelta: (maxLong - minLong) * 1.3)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    
    private func polyLine() -> [MulticolorPolyline] {
        
        // 1
        let locations = run.locations?.array as! [Location]
        var coordinates: [(CLLocation, CLLocation)] = []
        var speeds: [Double] = []
        var minSpeed = Double.greatestFiniteMagnitude
        var maxSpeed = 0.0
        
        // 2
        for (first, second) in zip(locations, locations.dropFirst()) {
            let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
            let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
            coordinates.append((start, end))
            
            //3
            let distance = end.distance(from: start)
            let time = second.timestamp!.timeIntervalSince(first.timestamp! as Date)
            let speed = time > 0 ? distance / time : 0
            speeds.append(speed)
            minSpeed = min(minSpeed, speed)
            maxSpeed = max(maxSpeed, speed)
        }
        
        //4
        let midSpeed = speeds.reduce(0, +) / Double(speeds.count)
        
        //5
        var segments: [MulticolorPolyline] = []
        for ((start, end), speed) in zip(coordinates, speeds) {
            let coords = [start.coordinate, end.coordinate]
            let segment = MulticolorPolyline(coordinates: coords, count: 2)
            segment.color = segmentColor(speed: speed,
                                         midSpeed: midSpeed,
                                         slowestSpeed: minSpeed,
                                         fastestSpeed: maxSpeed)
            segments.append(segment)
        }
        return segments
    }
    
    private func loadMap() {
        guard
            let locations = run.locations,
            locations.count > 0,
            let region = mapRegion()
            else {
                let alert = UIAlertController(title: "Error",
                                              message: "Sorry, this run has no locations saved",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
        }
        
        
        mapView.setRegion(region, animated: true)
        mapView.addOverlays(polyLine())
    }
    
    private func segmentColor(speed: Double, midSpeed: Double, slowestSpeed: Double, fastestSpeed: Double) -> UIColor {
        enum BaseColors {
            static let r_red: CGFloat = 1
            static let r_green: CGFloat = 20 / 255
            static let r_blue: CGFloat = 44 / 255
            
            static let y_red: CGFloat = 1
            static let y_green: CGFloat = 215 / 255
            static let y_blue: CGFloat = 0
            
            static let g_red: CGFloat = 0
            static let g_green: CGFloat = 146 / 255
            static let g_blue: CGFloat = 78 / 255
        }
        
        let red, green, blue: CGFloat
        
        if speed < midSpeed {
            let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
            red = BaseColors.r_red + ratio * (BaseColors.y_red - BaseColors.r_red)
            green = BaseColors.r_green + ratio * (BaseColors.y_green - BaseColors.r_green)
            blue = BaseColors.r_blue + ratio * (BaseColors.y_blue - BaseColors.r_blue)
        } else {
            let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
            red = BaseColors.y_red + ratio * (BaseColors.g_red - BaseColors.y_red)
            green = BaseColors.y_green + ratio * (BaseColors.g_green - BaseColors.y_green)
            blue = BaseColors.y_blue + ratio * (BaseColors.g_blue - BaseColors.y_blue)
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    
   
    
}
extension RecordController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MulticolorPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
    }
}
