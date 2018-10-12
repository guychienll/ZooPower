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
    
    private var aimedTimeTimer : Timer?
    private var aimedDistanceTimer : Timer?
    private var timerRunning = false
    private var distanceRunning = false
    var timerCount = 0
    var distanceCount = 0.0
    
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var oceanDistance = Measurement(value: 0, unit: UnitLength.meters)
     private var grassLandDistance = Measurement(value: 0, unit: UnitLength.meters)
     private var rainForestDistance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    //var demoLocationManager : CLLocationManager!
    var currentID = Auth.auth().currentUser?.uid
    var calorie : Double?
    var oceanRegion = false
    var grassLandRegion = false
    var rainForestRegion = false
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
        navigationController?.navigationItem.backBarButtonItem?.backgroundImage(for: .normal, barMetrics: .default)
  
        // 地圖樣式 // 顯示自身定位位置
        demoMapView.delegate = self
        demoMapView.mapType = .standard
        demoMapView.showsUserLocation = true
        
        // 允許縮放地圖
        demoMapView.isZoomEnabled = false
        demoMapView.isScrollEnabled = false
        demoMapView.isPitchEnabled = false
        demoMapView.isRotateEnabled = false
        setData()
        startLocationUpdates()
        
        
        if timerCount == 0 {
            timerRunning = false
        }
        
        if distanceCount == 0 {
            distanceRunning = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus()
            == .notDetermined {
            // 取得定位服務授權
            locationManager.requestAlwaysAuthorization()
            
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
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
            == .authorizedAlways {
            // 開始定位自身位置
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        aimedTimeTimer?.invalidate()
        aimedDistanceTimer?.invalidate()
        //locationManager.stopUpdatingLocation()
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    //timer popup setting
    func onSavetimer(_ data: Int) -> (){
        //timerLabel.text = String(data)
        timerCount = data
    }
    //distance popup setting
    func onSavedistance(_ data: Double) -> (){
        distanceCount = data
    }
    
    @objc func timerCounting(){
        if timerCount > 0 {
            print("\(timerCount)")
            timerCount -= 1
        } else {
            let alert = UIAlertController(title: "目標時間終止",
                                          message: "您設定的短期目標時間已達到",preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .cancel))
            present(alert, animated: true)
            self.timerRunning = false
            aimedTimeTimer?.invalidate()
        }
    }
    
    @objc func distanceCounting(){
        if distanceCount > 0 {
            if distance.value >= distanceCount{
                let alert = UIAlertController(title: "目標距離終止",
                                              message: "您設定的短期目標距離已達到",preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定", style: .cancel))
                present(alert, animated: true)
                self.distanceRunning = false
                aimedDistanceTimer?.invalidate()
            }
        }
        
        
    }
    func startTimer(){
        if timerRunning == false {
            aimedTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerCounting), userInfo: nil, repeats: true)
            timerRunning = true
        }
    }
    func startDistance(){
        if distanceRunning == false {
            aimedDistanceTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(distanceCounting), userInfo: nil, repeats: true)
            distanceRunning = true
        }
    }
    
    private func updateDisplay() {
        let formattedDistance = Double(round((distance.value / 1000) * 1000) / 1000)
        //print(distance.value)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = Double(round(((Double(seconds) / 60.0) / (distance.value / 1000)) * 1000) / 1000)
        distanceLabel.text = "\(formattedDistance)"
        timeLabel.text = "\(formattedTime)"
        paceLabel.text = "\(formattedPace)"
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation
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
            let roundedOceanDistance = Double(round(1000 * self.oceanDistance.value) / 1000)
            let roundedGrassLandDistance = Double(round(1000 * self.grassLandDistance.value) / 1000)
            let roundedRainForest = Double(round(1000 * self.rainForestDistance.value) / 1000)
            let roundedPace = Double(round(1000 * pace!) / 1000)
            let roundedCalorie = Double(round(100 * self.calorie!) / 100)
      
            //上傳跑步記錄到firebase
            let record = ["distance" : roundedDistance ,"duration" : self.seconds ,"date" : ServerValue.timestamp() ,"pace" : roundedPace , "calorie" : roundedCalorie , "oceanDistance" : roundedOceanDistance , "grassLandDistance" : roundedGrassLandDistance , "rainForestDistance" : roundedRainForest] as [AnyHashable : Any]
            Database.database().reference().child("Records/\(self.currentID!)").childByAutoId().setValue(record)
        })

        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRun.addToLocations(locationObject)
        }
        
        self.timerRunning = false
        self.distanceRunning = false
        timerCount = 0
        distanceCount = 0
        
        CoreDataStack.saveContext()
        run = newRun
        
        self.performSegue(withIdentifier: "singleRecordController", sender: nil)

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
        //locationManager.stopUpdatingLocation()
    }
    
    @IBAction func startTapped(_ sender: Any) {
        startRun()
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        oceanDistance = Measurement(value: 0, unit: UnitLength.meters)
        grassLandDistance = Measurement(value: 0, unit: UnitLength.meters)
        rainForestDistance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
        
        if timerCount > 0 {
            startTimer()
        }
        if distanceCount > 0 {
            startDistance()
        }
    }
    @IBAction func stopTapped(_ sender: Any) {
        let alertController  = UIAlertController(title: "End Run ?", message: "Do you wish to end your run ?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            self.stopRun()
            self.saveRun()
            
        }))
        present(alertController, animated: true)
    }
    
    func setData(){
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
            //海洋區域
            let ocean = "ocean"
            let oceanCoordinate = CLLocationCoordinate2DMake(37.702900, -121.754157)
            let oceanRegionRadius = 100.0
            let oceanRegion = CLCircularRegion(center: oceanCoordinate, radius: oceanRegionRadius, identifier: ocean)
        
            locationManager.startMonitoring(for: oceanRegion)
            let oceanAnnotation = MKPointAnnotation()
            oceanAnnotation.coordinate = oceanCoordinate
            oceanAnnotation.title = "\(ocean)"
            demoMapView.addAnnotation(oceanAnnotation)
            let oceanCircle = MKCircle(center: oceanCoordinate, radius: oceanRegionRadius)
            demoMapView.addOverlay(oceanCircle)

            //草原區域
            let grassLand = "grassLand"
            let grassLandCoordinate = CLLocationCoordinate2DMake(37.703011, -121.760170)
            let grassLandRegionRadius = 100.0
            let grassLandRegion = CLCircularRegion(center: grassLandCoordinate, radius: grassLandRegionRadius, identifier: grassLand)
            locationManager.startMonitoring(for: grassLandRegion)
            let grassLandAnnotation = MKPointAnnotation()
            grassLandAnnotation.coordinate = grassLandCoordinate
            grassLandAnnotation.title = "\(grassLand)"
            demoMapView.addAnnotation(grassLandAnnotation)
            let grassLandCircle = MKCircle(center: grassLandCoordinate, radius: grassLandRegionRadius)
            demoMapView.addOverlay(grassLandCircle)

            //雨林區域
            let rainForest = "rainForest"
            let rainForestCoordinate = CLLocationCoordinate2DMake(37.702081, -121.767189)
            let rainForestRegionRadius = 100.0
            let rainForestRegion = CLCircularRegion(center: rainForestCoordinate, radius: rainForestRegionRadius, identifier: rainForest)
            locationManager.startMonitoring(for: rainForestRegion)
            let rainForestAnnotation = MKPointAnnotation()
            rainForestAnnotation.coordinate = rainForestCoordinate
            rainForestAnnotation.title = "\(rainForest)"
            demoMapView.addAnnotation(rainForestAnnotation)
            let rainForestCircle = MKCircle(center: rainForestCoordinate, radius: rainForestRegionRadius)
            demoMapView.addOverlay(rainForestCircle)
        }
        else{
            print("System can't track region!")
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        var regionRenderer = MKCircleRenderer()
        
        //海洋區域
        if overlay.coordinate.latitude == 37.702900 , overlay.coordinate.longitude == -121.754157{
            regionRenderer = MKCircleRenderer(overlay: demoMapView.overlays[0])
            regionRenderer.strokeColor = UIColor.blue
            regionRenderer.fillColor = UIColor.init(red: 0/256, green: 0/256, blue: 256/256, alpha: 0.2)
            regionRenderer.lineWidth = 1.0
        }
        //草原區域
        else if overlay.coordinate.latitude == 37.703011 , overlay.coordinate.longitude == -121.760170{
            regionRenderer = MKCircleRenderer(overlay: demoMapView.overlays[1])
            regionRenderer.strokeColor = UIColor.red
            regionRenderer.fillColor = UIColor.init(red: 256/256, green: 0/256, blue: 0/256, alpha: 0.2)
            regionRenderer.lineWidth = 1.0
        }
        //雨林區域
        else if overlay.coordinate.latitude == 37.702081 , overlay.coordinate.longitude == -121.767189{
            regionRenderer = MKCircleRenderer(overlay: demoMapView.overlays[2])
            regionRenderer.strokeColor = UIColor.green
            regionRenderer.fillColor = UIColor.init(red: 0/256, green: 256/256, blue: 0/256, alpha: 0.2)
            regionRenderer.lineWidth = 1.0
        }

        return regionRenderer
    }
    
  
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
      
        if region.identifier == "ocean"{
             self.oceanRegion = true
            let alert = UIAlertController(title: "海洋區進入通知", message: "你已進入海洋區", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .cancel))
            present(alert, animated: true, completion: nil)
        }else if region.identifier == "grassLand"{
            self.grassLandRegion = true
            let alert = UIAlertController(title: "草原區進入通知", message: "你已進入草原區", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .cancel))
            present(alert, animated: true, completion: nil)
        }else if region.identifier == "rainForest"{
            self.rainForestRegion = true
            let alert = UIAlertController(title: "雨林區進入通知", message: "你已進入雨林區", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確認", style: .cancel))
            present(alert, animated: true, completion: nil)
        }
        
    
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if region.identifier == "ocean"{
            self.oceanRegion = false
            let alert = UIAlertController(title: "海洋區離開通知", message: "你已離開海洋區", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確認", style: .cancel))
            present(alert, animated: true, completion: nil)
        }else if region.identifier == "grassLand"{
            self.grassLandRegion = false
            let alert = UIAlertController(title: "草原區離開通知", message: "你已離開草原區", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確認", style: .cancel))
            present(alert, animated: true, completion: nil)
        }else if region.identifier == "rainForest"{
            self.rainForestRegion = false
            let alert = UIAlertController(title: "雨林區離開通知", message: "你已離開雨林區", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確認", style: .cancel))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier { // 检查是否 nil
            switch identifier {
            case "singleRecordController":
                if let destination = segue.destination as? singleRecordController {
                    destination.run = run
                }
            case "totimerPopControllersegue" :
                if let destination = segue.destination as? timePopController{
                    destination.onSavetimer = onSavetimer
                }
            case "totdistancePopControllersegue" :
                if let destination = segue.destination as? distancePopController{
                    destination.onSavedistance = onSavedistance
                }
                
            default: break
            }
        }
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
            
            if self.oceanRegion == true {
                if let lastLocation = locationList.last {
                    let delta = newLocation.distance(from: lastLocation)
                    oceanDistance = oceanDistance + Measurement(value: delta, unit: UnitLength.meters)
                }
            }else if self.grassLandRegion == true {
                if let lastLocation = locationList.last {
                    let delta = newLocation.distance(from: lastLocation)
                    grassLandDistance = grassLandDistance + Measurement(value: delta, unit: UnitLength.meters)
                }
            }else if self.rainForestRegion == true {
                if let lastLocation = locationList.last {
                    let delta = newLocation.distance(from: lastLocation)
                    rainForestDistance = rainForestDistance + Measurement(value: delta, unit: UnitLength.meters)
                }
            }
            
            locationList.append(newLocation)
        }
        // 印出目前所在位置座標
        let currentLocation :CLLocation =
            locations[0] as CLLocation
        
        // 地圖預設顯示的範圍大小 (數字越小越精確)
        let latDelta = 0.01
        let longDelta = 0.01
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


