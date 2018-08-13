//
//  UsersDataController.swift
//  ZooPower
//
//  Created by Chienli on 2018/8/3.
//  Copyright © 2018 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UsersDataController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate ,UITextFieldDelegate{
    
    var ref : DatabaseReference?
    var storageRef : StorageReference?
    var facebookID : String = ""
    var googleID : String = ""
    var gender : String = "Male"
    
    @IBOutlet weak var userDataScrollView: UIScrollView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!{
        didSet{
            userNameTextField.tag = 1
            userNameTextField.delegate = self
        }
    }
    @IBOutlet weak var userGenderSegmentedController: UISegmentedControl!
    @IBOutlet weak var userBirthdayTextField: UITextField!
    @IBOutlet weak var userHeightTextField: UITextField!{
        didSet{
            userHeightTextField.keyboardType = .numbersAndPunctuation
            userHeightTextField.tag = 2
            userHeightTextField.delegate = self
        }
    }
    @IBOutlet weak var userWeightTextField: UITextField!{
        didSet{
            userWeightTextField.keyboardType = .numbersAndPunctuation
            userWeightTextField.tag = 3
            userWeightTextField.delegate = self
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //鍵盤跳出 元件閃避上移
        userDataScrollView.setContentOffset(CGPoint(x: 0, y: 145), animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField間 互相換行
        if let nextTextField = view.viewWithTag(textField.tag + 1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //鍵盤收起 所有元件回到原位
        userDataScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageName = UUID().uuidString
        ref = Database.database().reference()
        storageRef = Storage.storage().reference().child("/userProfileImage/\(imageName).png")
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
        
        //觀察popup動靜
        NotificationCenter.default.addObserver(self, selector: #selector(handlePopupClosing), name: .saveDateTime, object: nil)
        
       
    }
    
    //設定日期為picker挑選的日期
    @objc func handlePopupClosing(notification : Notification) {
        let dateVc = notification.object as! DatePopupController
        userBirthdayTextField.text = dateVc.formattedDate
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
            //self.userNameTextField.isEnabled = false
        })
    }
    
    //google userName automatically load 使用者名稱自動代入
    fileprivate func googleUserName(){
        ref?.child("Users/\(googleID)/name").observeSingleEvent(of: .value, with: { (snapshot) in
            let name = snapshot.value as? String
            self.userNameTextField.text = name
            //self.userNameTextField.isEnabled = false
        })
    }
    
    
    // gerderController
    @IBAction func genderSegmentedController(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            gender = "Male"
        }else{
            gender = "Female"
        }
    }
    
    //使用者自行更換照片
    @IBAction func editPhotoButton(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            print(editedImage.size)
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[.originalImage] as? UIImage {
            print(originalImage.size)
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.userImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
        
    }
    
    //Update User's Data to Firebase ( PictureURL , Birthday , Height , Weight , Gender )
    @IBAction func okButton(_ sender: Any) {
        if facebookID != "" {
            let uploadData = self.userImageView.image?.pngData()
            //upload image to firebase storage
            storageRef?.putData(uploadData!, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error ?? "")
                    return
                }
                
                self.storageRef?.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    if let profileImageUrl = url?.absoluteString {
                        let values = ["picture" : profileImageUrl , "birthday" : self.userBirthdayTextField.text ?? "" , "height" : self.userHeightTextField.text ?? "" , "weight" : self.userWeightTextField.text ?? "" , "gender" : self.gender] as [AnyHashable : Any]
                        self.ref?.child("Users/\(self.facebookID)").updateChildValues(values)
                    }
                })
                
                
            })
            
        }else{
            let uploadData = self.userImageView.image?.pngData()
            //upload image to firebase storage
            storageRef?.putData(uploadData!, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error ?? "")
                    return
                }
                self.storageRef?.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    if let profileImageUrl = url?.absoluteString {
                        let values = ["picture" : profileImageUrl , "birthday" : self.userBirthdayTextField.text ?? "" , "height" : self.userHeightTextField.text ?? "" , "weight" : self.userWeightTextField.text ?? "" , "gender" : self.gender] as [AnyHashable : Any]
                        self.ref?.child("Users/\(self.googleID)").updateChildValues(values)
                    }
                })
                
            })
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
