//
//  AddfriendController.swift
//  ZooPower
//
//  Created by 朱一心 on 2018/10/17.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
class AddfriendController: UITableViewController,UITextFieldDelegate {
    var users = [Users]()
    let cellId = "cellId"
    let currentID = Auth.auth().currentUser?.uid
    let currentNAME = Auth.auth().currentUser?.displayName
      
    
    
    
    
    // UITextField初始化
    var titleView = UIImageView(frame: CGRect(x: 85, y: 0, width: 200, height: 140))
    let dyTextField: UITextField = UITextField(frame: CGRect(x: 35.0, y: 150.0, width: 275.0, height: 40.0))
    let TBDLabel = UILabel(frame: CGRect(x: 120, y: 440, width: 80, height: 80))
    var myImageView = UIImageView(frame: CGRect(x: 130, y: 230, width: 120, height: 120))
    var myImageView1 = UIImageView(frame: CGRect(x: 30, y: 450, width: 60, height: 60))
    let myLabel = UILabel(frame: CGRect(x: 90, y: 330, width: 200, height: 80))
    var addbutton = UIButton(frame: CGRect(x: 115, y:395, width: 150, height: 40))
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        var back = UIImage(named:"left-arrow")
        back = back?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: back,style: .plain,target: self,action: #selector(handleCancel))
        
        
        //searchbutton
        let button = UIButton(frame: CGRect(x: 325, y: 155, width: 28, height: 40))
        let buttonimage = UIImage(named: "transparency")
        button.setBackgroundImage(buttonimage , for: UIControl.State.normal)
        
       titleView.image = UIImage(named: "search")
        self.view.addSubview(titleView)
        // 設定文字顏色
        dyTextField.textColor = UIColor.gray
        // Delegate
        dyTextField.delegate = self as! UITextFieldDelegate
        tableView.separatorStyle = .none
        // 設定輸入框背景顏色
        dyTextField.backgroundColor = UIColor.white
        dyTextField.keyboardType = .webSearch
        // 框線樣式
        dyTextField.borderStyle = UITextField.BorderStyle.roundedRect
        dyTextField.placeholder = "enter your friend's ID"
        self.dyTextField.clearButtonMode = UITextField.ViewMode.always
        self.dyTextField.clearsOnBeginEditing = true
        
        // 將TextField加入View
        self.view.addSubview(dyTextField)
        self.view.addSubview(button)
        
        
        button.addTarget(self, action: #selector(dyTextFieldButton), for: .touchUpInside)
        
    
       
        
    }
   
     func TBD(){
        
        
        
        
        
        Database.database().reference().child("FriendTBD/\(self.currentID!)").observe(.childAdded, with:{(snapshot) in
           
            if var values = snapshot.value as? [String: AnyObject]{
                let TBD =  FriendTBD()
                
                TBD.toId = values["toId"] as? String
                TBD.fromId = values["fromId"] as? String
                if TBD.toId == self.currentID {
                    
                    
                    Database.database().reference().child("Users/\(TBD.fromId!)/name").observe(.value, with: { (snap) in
                        
                        var name = snap.value as! String
                       
                        
                        
                        print(name)
                        self.TBDLabel.text = name
                        
                        
                        self.view.addSubview(self.TBDLabel)
                    })
                    Database.database().reference().child("Users/\(TBD.fromId!)/picture").observe(.value, with: { (snap) in
                        let picture = snap.value as! String
                        //get image's url
                        
                        //download image
                        let url = NSURL(string: picture)
                        
                        URLSession.shared.dataTask(with : url! as URL , completionHandler :{ (data, URLResponse, error) in
                            
                            //download hit an error
                            if error != nil{
                                print(error)
                                return
                            }
                            DispatchQueue.main.async {
                                self.myImageView1.image = UIImage(data: data!)
                            }
                            
                        }).resume()
                        
                        self.myImageView1.layer.cornerRadius = 30.0
                        self.myImageView1.clipsToBounds = true
                        self.myImageView1.contentMode = .scaleAspectFill
                        
                        self.view.addSubview(self.myImageView1)
                        
                    })
                    
                    
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    
    
    @objc func dyTextFieldButton(){
        Database.database().reference().child("Users").observe(.childAdded, with:{(snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = Users()
                user.id = snapshot.key
                if user.id != Auth.auth().currentUser?.uid{
                    let data =  dictionary
                    user.name = data["name"] as! String
                    user.picture = data["picture"] as? String
                    //this will crash because of backgroundtheard,so lets use dispatch_async to fix
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    Database.database().reference().child("Friend/\(self.currentID!)").observe(.childAdded, with:{(snapshot) in
                        if var value = snapshot.value as? [String: AnyObject]{
                            let FRI = Friend()
                            FRI.name = value["name"] as? String
                           
                            if FRI.name == self.dyTextField.text{
                                
                                let addButtonImage = UIImage(named: "cancel")
                                
                                self.addbutton.setBackgroundImage(addButtonImage , for: UIControl.State.normal)
                                self.addbutton.isEnabled=false
                                
                            }
                        }
                         })
                    self.gotUser(user: user)
                }
            }
        })
        
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    
    func gotUser(user: Users){
        
      
        if self.dyTextField.text == user.name   {
            
            // 文字內容
            myLabel.text = user.name
            // 文字顏色
            myLabel.textColor = UIColor.black
            // 文字的大小
            myLabel.font = myLabel.font.withSize(24.0)
            // 文字行數
            myLabel.numberOfLines = 1
            myLabel.textAlignment = NSTextAlignment.center
            
            self.view.addSubview(myLabel)
            
            //get image's url
            if let picture = user.picture{
                //download image
                let url = NSURL(string: picture)
                
                URLSession.shared.dataTask(with : url! as URL , completionHandler :{ (data, URLResponse, error) in
                    
                    
                    //download hit an error
                    if error != nil{
                        print(error)
                        return
                    }
                    DispatchQueue.main.async {
                        self.myImageView.image = UIImage(data: data!)
                    }
                    
                }).resume()
                
                myImageView.layer.cornerRadius = 60.0
                myImageView.clipsToBounds = true
                myImageView.contentMode = .scaleAspectFill
                
                self.view.addSubview(myImageView)
            }
            
            
            self.addbutton.isEnabled=true
            let addButtonImage = UIImage(named: "ok")
            self.addbutton.setBackgroundImage(addButtonImage , for: UIControl.State.normal)
            
        
            
            
            self.view.addSubview(addbutton)
            addbutton.addTarget(self, action: #selector(add), for: .touchUpInside)
            
            
          
            
            Database.database().reference().child("FriendTBD/\(user.id!)").observe(.childAdded, with:{(snapshot) in
           
                if var values = snapshot.value as? [String: AnyObject]{
                    
                  
                    let TBD =  FriendTBD()
                    
                    
                    TBD.fromId = values["fromId"] as? String
                    TBD.toName = values["toName"] as? String
                    
                    if TBD.fromId == self.currentID && TBD.toName == self.dyTextField.text {
                         let addButtonImage = UIImage(named: "cancel")
                        
                        self.addbutton.setBackgroundImage(addButtonImage , for: UIControl.State.normal)
                        self.addbutton.isEnabled=false
                        
                        }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                
            }
                
                })
            
        }
    }
    
    
    
    
    @objc func add(){
        
        Database.database().reference().child("Users").observe(.childAdded, with:{(snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = Users()
                user.id = snapshot.key
                if user.id != Auth.auth().currentUser?.uid{
                    let data =  dictionary
                    user.name = data["name"] as! String
                    user.picture = data["picture"] as? String
                    //this will crash because of backgroundtheard,so lets use dispatch_async to fix
                    
                    if self.dyTextField.text == user.name {
                        
                        let userid = user.id
                        let ref = Database.database().reference().child("FriendTBD").child(userid!).child(self.currentID!)
                       
                        let childRef = ref
                        
                        let toId = user.id
                         let fromName = self.currentNAME
                        let toName = user.name
                        let fromId = self.currentID
                       
                       
                        
                        var values = ["toId":toId,"fromId":fromId,"fromName":fromName,"toName":toName] as [String : AnyObject]
                        
                        childRef.updateChildValues(values){ (error,ref) in
                            if error != nil{
                                print(error)
                                return
                            }
                            
                            
                            
                            
                            
                        }
                        
                       
                        
                    }}
            }
        })
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    
}
