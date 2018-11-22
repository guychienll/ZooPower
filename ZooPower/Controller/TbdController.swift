//
//  TbdController.swift
//  ZooPower
//
//  Created by 朱一心 on 2018/11/7.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
class TbdController: UITableViewController {
let currentID = Auth.auth().currentUser?.uid
    var FriendTBDs = [FriendTBD]()
    let cellId = "cellId"
    var tbdController : TbdController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        var back = UIImage(named:"left-arrow")
        back = back?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: back,style: .plain,target: self,action: #selector(handleCancel))
          var titleView = UIImageView(frame: CGRect(x: 127, y: -40, width: 115, height: 40))
        titleView.image = UIImage(named: "ready")
        self.view.addSubview(titleView)
         tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
          fetchUser()
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
       
        let deleteAction = UITableViewRowAction(style: .destructive, title: "delete") { (action, actionIndexPath) in
            let TBD = self.FriendTBDs[indexPath.row]
            Database.database().reference().child("FriendTBD/\(self.currentID!)").child(TBD.fromId!).removeValue { (error, ref) in
                if error != nil{
                    print(error!)
                    return
                }
                
            }
            
            self.FriendTBDs.remove(at: indexPath.row)
           tableView.reloadData()
            
        }
        let addAction = UITableViewRowAction(style: .normal, title: "add") { (action, actionIndexPath) in
            let TBD = self.FriendTBDs[indexPath.row]
            Database.database().reference().child("FriendTBD/\(self.currentID!)").child(TBD.fromId!).removeValue { (error, ref) in
                if error != nil{
                    print(error!)
                    return
                }
                
            }
            let fromName = TBD.fromName
            
            let fromId = TBD.fromId
            let toName = TBD.toName
            
            let toId = TBD.toId
          
            
                let ref = Database.database().reference().child("Friend").child(self.currentID!).child(TBD.fromId!)
            Database.database().reference().child("Users/\(TBD.fromId!)/picture").observe(.value, with: { (snap) in
                let picture = snap.value as! String
                
            var valuee = ["id":fromId,"name":fromName,"picture": picture] as [String : AnyObject]
            
             ref.updateChildValues(valuee){ (error,ref) in
                if error != nil{
                    print(error)
                    return
                }
           
            }})
            
                let recipient = Database.database().reference().child("Friend").child(TBD.fromId!).child(self.currentID!)
            Database.database().reference().child("Users/\(TBD.toId!)/picture").observe(.value, with: { (snap) in
                let picture = snap.value as! String
                
                
                let url = NSURL(string: picture)
                
                URLSession.shared.dataTask(with : url! as URL , completionHandler :{ (data, URLResponse, error) in
                    
                    //download hit an error
                    if error != nil{
                        print(error)
                        return
                    }
                   
                    
                }).resume()
            
            
                var value = ["id":toId,"name":toName,"picture": picture] as [String : AnyObject]
            recipient.updateChildValues(value){ (error,ref) in
                if error != nil{
                    print(error)
                    return
                }
                
            }
                })
            self.FriendTBDs.remove(at: indexPath.row)
            
            tableView.reloadData()
        }
            
        
       
        return [deleteAction,addAction]
    }
   
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FriendTBDs.count
    }

   
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    func fetchUser(){
        
        
        Database.database().reference().child("FriendTBD/\(self.currentID!)").observe(.childAdded, with:{(snapshot) in
            
            if let values = snapshot.value as? [String: AnyObject]{
                let TBD =  FriendTBD()
                
                TBD.toId = values["toId"] as? String
                TBD.fromId = values["fromId"] as? String
                
                if TBD.toId == self.currentID{
                   let data =  values
                       TBD.fromName = data["fromName"] as? String
                     TBD.toName = data["toName"] as? String
                    
                    
                  self.FriendTBDs.append(TBD)
                   
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                   
                }}
        })
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId,for: indexPath)  as! UserCell
       
        
        //cell.textLabel?.text = TBD.fromName
        let TBD = FriendTBDs[indexPath.row]
        cell.textLabel?.text = TBD.fromName
       
        Database.database().reference().child("Users/\(TBD.fromId!)/picture").observe(.value, with: { (snap) in
            let picture = snap.value as! String
           
        
        let url = NSURL(string: picture)
        
        URLSession.shared.dataTask(with : url! as URL , completionHandler :{ (data, URLResponse, error) in
            
            //download hit an error
            if error != nil{
                print(error)
                return
            }
            DispatchQueue.main.async {
                 cell.profileImageView.image = UIImage(data: data!)
            }
            
        }).resume()
            })
        
        return cell
        
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
