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
    var onSavedistance : ((_ data: Int) -> ())?
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if distanceCount == 0 {
            distanceRunning = false
        }
    }
   
    @IBAction func okButton(sender: UIButton){
        //unwrap textField and Display result
        if let countebleNumber = Int(textField.text!) {
            distanceCount = Int(countebleNumber)*1000
        }
        onSavedistance?(distanceCount)
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
