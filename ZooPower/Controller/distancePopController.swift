//
//  distancePopController.swift
//  ZooPower
//
//  Created by User8 on 2018/9/9.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Foundation

class distancePopController: UIViewController, UITextFieldDelegate {

    var distanceCount = 0
    var distanceRunning = false
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if distanceCount == 0 {
            distanceRunning = false
        }
    }
    
    //Figure out Count method
    @objc func Counting() {
        if distanceCount > 0 {
            print("\(distanceCount)")
            //get from data from user's run distance
            distanceCount -= Int(round((distance.value / 1000) * 1000)/1000)
        } else {
            print("times up for distance")
        }
    }
    
    //ADD Action Button
    @IBAction func okButton(sender: UIButton) {
        //unwrap textField and Display result
        if let countebleNumber = Int(textField.text!) {
            distanceCount = Int(countebleNumber)*1000
        }
    }
    
    
    @IBAction func distanceStartCountingDown(sender: Any){
        if distanceRunning == false {
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(distancePopController.Counting), userInfo: nil, repeats: true)
            distanceRunning = true
        }
    }
    
    @IBAction func distanceCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
