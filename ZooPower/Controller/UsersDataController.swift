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
    var googleID : String = ""
    var gender : String = "Male"
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userGenderSegmentedController: UISegmentedControl!
    @IBOutlet weak var userBirthdayTextField: UITextField!
    @IBOutlet weak var userHeightTextField: UITextField!
    @IBOutlet weak var userWeightTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        // userPicture automatically load 使用者名稱自動代入
        if facebookID != "" {
            facebookUserPicture()
        }else{
             googleUserPicture()
        }
        
        
        // userName automatically load 使用者名稱自動代入
        if facebookID != "" {
            facebookUserName()
        }else{
            googleUserName()
        }
        
    }
    
    //Facebook userPicture automatically load 大頭貼自動代入
    fileprivate func facebookUserPicture() {
        self.userImageView.load(url: URL(string: "https://graph.facebook.com/\(facebookID)/picture?height=480&width=480")!)
    }
    
    //google userPicture automatically load 大頭貼自動代入
    fileprivate func googleUserPicture(){
        
        self.ref?.child("Users/\(googleID)/picture").observeSingleEvent(of: .value, with: { (snapshot) in
            let googleUserPicture = snapshot.value as? String
            self.userImageView.load(url: URL(string: googleUserPicture!)!)
        })
    }
    
    //Facebook userName automatically load 使用者名稱自動代入
    fileprivate func facebookUserName(){
        ref?.child("Users/\(facebookID)/name").observeSingleEvent(of: .value, with: { (snapshot) in
            let name = snapshot.value as? String
            self.userNameTextField.text = name
            self.userNameTextField.isEnabled = false
        })
    }
    
    //google userName automatically load 使用者名稱自動代入
    fileprivate func googleUserName(){
        ref?.child("Users/\(googleID)/name").observeSingleEvent(of: .value, with: { (snapshot) in
            let name = snapshot.value as? String
            self.userNameTextField.text = name
            self.userNameTextField.isEnabled = false
        })
    }
    
    // keyboard end to exit
    @IBAction func nameTextField(_ sender: Any) {
    }
    // keyboard end to exit
    @IBAction func birthdayTextField(_ sender: Any) {
    }
    // keyboard end to exit
    @IBAction func heightTextField(_ sender: Any) {
    }
    // keyboard end to exit
    @IBAction func weightTextField(_ sender: Any) {
    }
    // gerderController
    @IBAction func genderSegmentedController(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            gender = "Male"
        }else{
            gender = "Female"
        }
    }
    
    //Update User's Data to Firebase ( Birthday , Height , Weight , Gender )
    @IBAction func okButton(_ sender: Any) {
        let values = ["birthday" : userBirthdayTextField.text , "height" : userHeightTextField.text , "weight" : userWeightTextField.text , "gender" : gender] as [AnyHashable : Any]
        if facebookID != "" {
            ref?.child("Users/\(facebookID)").updateChildValues(values)
        }else{
            ref?.child("Users/\(googleID)").updateChildValues(values)
        }
        
    }
    
    // Back to Login View controller
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
