//
//  MessageController.swift
//  ZooPower
//
//  Created by 朱一心 on 2018/8/17.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
class MessageController: UITableViewController {
    let cellId = "cellId"
    let currentID = Auth.auth().currentUser?.uid
    var friends = [Friend]()
    var users = [Users]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
        var titleView = UIImageView(frame: CGRect(x: 123, y: -40, width: 130, height: 50))
        
        var back = UIImage(named:"left-arrow")
        back = back?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: back,style: .plain,target: self,action: #selector(handleCancel))
        
        var image = UIImage(named: "add-friend")
        image = image?.withRenderingMode(.alwaysOriginal)
        let searchWithIdButton = UIBarButtonItem(image :image, style: .plain, target: self,action: #selector(addfriend))
        
        var Tbd = UIImage(named: "tbd")
        Tbd = Tbd?.withRenderingMode(.alwaysOriginal)
        let TbdButton = UIBarButtonItem(image : Tbd , style: .plain, target: self,action: #selector(TbdFriend))
        
        
        
        navigationItem.rightBarButtonItems = [searchWithIdButton , TbdButton]
        
        titleView.image = UIImage(named: "title")
        self.view.addSubview(titleView)
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
        
        
        
        
        
        
        
    }
    @objc func TbdFriend(){
        let tbdController = TbdController()
        
        
        //cancel的button按了返回
        let navContrller = UINavigationController(rootViewController:tbdController)
        present(navContrller , animated:true,completion: nil)
        
    }
    
    
    
    @objc func addfriend(){
        let addfriendController = AddfriendController()
        
        
        //cancel的button按了返回
        let navContrller = UINavigationController(rootViewController:addfriendController)
        present(navContrller , animated:true,completion: nil)
        
        
        
    }
    //抓資料庫的資料
    func fetchUser(){
        
        
        Database.database().reference().child("Friend/\(self.currentID!)").observe(.childAdded, with:{(snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let friend = Friend()
                
                friend.id = snapshot.key
                if friend.id != Auth.auth().currentUser?.uid{
                    let data =  dictionary
                    friend.name = data["name"] as? String
                    friend.picture = data["picture"] as? String
                    
                    self.friends.append(friend)
                    
                    
                    
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    
                }}
        })
        
        
    }
    
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    //reference兩個controller才可用showChatController
    var chatController : ChatController?
    //slider dwon this controller (換頁）
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true){
            
            //分辨出點的好友是誰 如果想將其傳至chatcontroller必須經由showChatControllerForUser(user: user)
            let friend = self.friends[indexPath.row]
            
            //顯示chatcontroller
            self.chatController?.showChatControllerForUser(friend: friend)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friends.count
    }
    //return its cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let use a hack for now , we actually need to dequeue our cell for memory
        
        //as! UserCell ->使用到下面constrains
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId,for: indexPath) as! UserCell
        
        let friend = friends[indexPath.row]
        cell.textLabel?.text = friend.name
        
        
        
        
        
        //get image's url
        if let profileImageUrl = friend.picture{
            
            let url = NSURL(string: profileImageUrl)
            
            URLSession.shared.dataTask(with : url! as URL , completionHandler :{ (data, URLResponse, error) in
                
                
                if error != nil{
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.profileImageView.image = UIImage(data: data!)
                    
                    
                    
                }
                
            }).resume()
            
        }
        return cell
        
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}

