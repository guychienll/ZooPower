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
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance,
                                               seconds: seconds,
                                               outputUnit: UnitSpeed.secondsPerMeter)
        
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
        
        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRun.addToLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        
        run = newRun
        ref = Database.database().reference()
        print(self.currentID!)
        //ref?.child("/Users/\(self.currentID!)/")
        print(run ?? "default value")
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


