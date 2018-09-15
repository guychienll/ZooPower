//
//  timePopController.swift
//  ZooPower
//
//  Created by User8 on 2018/9/9.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Foundation

class timePopController: UIViewController, UITextFieldDelegate {
    
    var timerCount = 0
    var timerRunning = false
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if timerCount == 0 {
            timerRunning = false
        }
    }
    
    //Figure out Count method
    @objc func Counting() {
        if timerCount > 0 {
            print("\(timerCount)")
            timerCount -= 1
        } else {
            print("times up")
        }
    }
    
    //ADD Action Button
    @IBAction func okButton(sender: UIButton) {
        //unwrap textField and Display result
        if let countebleNumber = Double(textField.text!) {
            timerCount = Int(countebleNumber*60)
        }
    }
    

    @IBAction func timmerStartCountingDown(sender: Any){
     if timerRunning == false {
     _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timePopController.Counting), userInfo: nil, repeats: true)
     timerRunning = true
     }
     }
    
    @IBAction func timmerCloseButton(_ sender: Any) {
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

