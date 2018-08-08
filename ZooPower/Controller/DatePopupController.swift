//
//  DatePopupController.swift
//  ZooPower
//
//  Created by User8 on 2018/8/8.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class DatePopupController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    var formattedDate : String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: datePicker.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBAction func saveDate_TouchUpInside(_ sender: Any) {
        
       NotificationCenter.default.post(name: .saveDateTime, object: self)
        
        dismiss(animated: true, completion: nil)
        
    }
    

}
