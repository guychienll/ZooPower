//
//  UsersDataController.swift
//  ZooPower
//
//  Created by Chienli on 2018/8/3.
//  Copyright © 2018 com.fjuim. All rights reserved.
//

import UIKit
import Firebase

class UsersDataController: UIViewController {
    
    var ref : DatabaseReference?
    var facebookID : String = ""
    
    
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.userImageView.load(url: URL(string: "https://graph.facebook.com/\(facebookID)/picture?height=480&width=480")!)
        
    }
    
    @IBAction func nameTextField(_ sender: Any) {
    }
    @IBAction func birthdayTextField(_ sender: Any) {
    }
    @IBAction func heightTextField(_ sender: Any) {
    }
    @IBAction func weightTextField(_ sender: Any) {
    }
    @IBAction func cancelButton(_ sender: Any) {
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
