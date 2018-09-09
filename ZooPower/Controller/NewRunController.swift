//
//  RunViewController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/14.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase


class NewRunController: UIViewController , MKMapViewDelegate{
    
    private var run: Run?
    var ref : DatabaseReference?
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    var demoLocationManager : CLLocationManager!
    var currentID = Auth.auth().currentUser?.uid
    var calorie : Double?
    @IBOutlet weak var demoMapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //隱藏navigationbar（透明化）
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Do any additional setup after loading the view.
        demoLocationManager = CLLocationManager()
        demoLocationManager.delegate = self
        demoLocationManager.distanceFilter = kCLLocationAccuracyBestForNavigation
        
        //隱藏navigationbar（透明化）
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationItem.backBarButtonItem?.backgroundImage(for: .normal, barMetrics: .default)
        
        demoMapView.delegate = self
        
        // 地圖樣式
        demoMapView.mapType = .standard
        
        // 顯示自身定位位置
        demoMapView.showsUserLocation = true
        
        // 允許縮放地圖
        demoMapView.isZoomEnabled = false
        demoMapView.isScrollEnabled = false
        demoMapView.isPitchEnabled = false
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus()
            == .notDetermined {
            // 取得定位服務授權
            demoLocationManager.requestWhenInUseAuthorization()
            
            // 開始定位自身位置
            demoLocationManager.startUpdatingLocation()
        }
            // 使用者已經拒絕定位自身位置權限
        else if CLLocationManager.authorizationStatus()
            == .denied {
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(
                title: "定位權限已關閉",
                message:
                "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(
                alertController,
                animated: true, completion: nil)
        }
            // 使用者已經同意定位自身位置權限
        else if CLLocationManager.authorizationStatus()
            == .authorizedWhenInUse {
            // 開始定位自身位置
            demoLocationManager.startUpdatingLocation()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedDistance = Double(round((distance.value / 1000) * 1000) / 1000)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = Double(round(((Double(seconds) / 60.0) / (distance.value / 1000)) * 1000) / 1000)
        distanceLabel.text = "\(formattedDistance)"
        timeLabel.text = "\(formattedTime)"
        paceLabel.text = "\(formattedPace)"
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
    private func saveRun() {
        let newRun = Run(context: CoreDataStack.context)
        newRun.distance = distance.value
        newRun.duration = Int16(seconds)
        newRun.timestamp = Date()
        var pace : Double?
        if String(Double(seconds) / distance.value) == "inf" {
            pace = 0
        }else{
            pace = Double(seconds) / distance.value
        }
  
        Database.database().reference().child("Users/\(currentID!)/weight").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //取得體重
            let value = snapshot.value as? String
            let weight = Double(value!)
            
            //計算卡路里
            self.calorieCompute(weight: weight! , pace : pace!)
            
           //四捨五入
            let roundedDistance = Double(round(1000 * self.distance.value) / 1000)
            let roundedPace = Double(round(1000 * pace!) / 1000)
            let roundedCalorie = Double(round(100 * self.calorie!) / 100)
      
            //上傳跑步記錄到firebase
            let record = ["distance" : roundedDistance ,"duration" : self.seconds ,"date" : ServerValue.timestamp() ,"pace" : roundedPace , "calorie" : roundedCalorie] as [AnyHashable : Any]
            Database.database().reference().child("Records/\(self.currentID!)").childByAutoId().setValue(record)
        })

        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRun.addToLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        run = newRun
       
    }
    
    //卡路里計算方法
    private func calorieCompute(weight:Double , pace : Double){
        //kalulixiaohao.51240.com
        switch (distance.value / 1000) / (Double(seconds) / 3600) {
        case ...8.0:
            calorie = (pace * distance.value) / 60 * weight * 0.1563
        case 8.0...8.4:
            calorie = (pace * distance.value) / 60 * weight * 0.1788
        case 8.4...9.7:
            calorie = (pace * distance.value) / 60 * weight * 0.201
        case 9.7...10.8:
            calorie = (pace * distance.value) / 60 * weight * 0.2233
        case 10.8...11.3:
            calorie = (pace * distance.value) / 60 * weight * 0.2345
        case 11.3...12.1:
            calorie = (pace * distance.value) / 60 * weight * 0.2568
        case 12.1...12.9:
            calorie = (pace * distance.value) / 60 * weight * 0.2793
        case 12.9...13.8:
            calorie = (pace * distance.value) / 60 * weight * 0.2903
        case 13.8...14.5:
            calorie = (pace * distance.value) / 60 * weight * 0.3128
        case 14.5...16.0:
            calorie = (pace * distance.value) / 60 * weight * 0.335
        case 16.0...:
            calorie = (pace * distance.value) / 60 * weight * 0.3798
        default:
            print("default")
        }
    }
    
    private func startRun() {
        startButton.isHidden = true
        stopButton.isHidden = false
    }
    
    private func stopRun() {
        startButton.isHidden = false
        stopButton.isHidden = true
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func startTapped(_ sender: Any) {
        startRun()
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
    }
    @IBAction func stopTapped(_ sender: Any) {
        let alertController  = UIAlertController(title: "End Run ?", message: "Do you wish to end your run ?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            self.stopRun()
            self.saveRun()
            self.performSegue(withIdentifier: "RunDetailsController", sender: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { (_) in
            _ = self.navigationController?.popToRootViewController(animated: true)
        }))
        present(alertController, animated: true)
    }
    
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? RunDetailsController
        destination?.run = run
    }
    
    
}

extension NewRunController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            
            locationList.append(newLocation)
        }
        // 印出目前所在位置座標
        let currentLocation :CLLocation =
            locations[0] as CLLocation
        
        // 地圖預設顯示的範圍大小 (數字越小越精確)
        let latDelta = 0.001
        let longDelta = 0.001
        let currentLocationSpan:MKCoordinateSpan =
            MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        // 設置地圖顯示的範圍與中心點座標
        let center:CLLocation = CLLocation(
            latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let currentRegion:MKCoordinateRegion =
            MKCoordinateRegion(
                center: center.coordinate,
                span: currentLocationSpan)
        demoMapView.setRegion(currentRegion, animated: true)
    }
}


