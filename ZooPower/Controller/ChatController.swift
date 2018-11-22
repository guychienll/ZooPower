//
//  ChatController.swift
//  ZooPower
//
//  Created by 朱一心 on 2018/8/17.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
let imageCache = NSCache<AnyObject, AnyObject>()
//本來是內建的但現在沒有
extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        // check cache for image first
        
        if  let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        
        let url = NSURL(string: urlString)
        
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error ?? 0)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                    
                }
                
            }
            
        }).resume()
        
    }
    
}

class ChatController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    
    
    
    
    
    
    let cellId = "Cell"
    var ref : DatabaseReference?
    
    var currentID = Auth.auth().currentUser?.uid
    
    
    
    
    @IBOutlet weak var firstTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let green =  UIColor(red: 173/255.0, green: 199/255.0, blue: 201/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.barTintColor = green
        
        
        
        firstTableView.delegate = self
        firstTableView.dataSource = self
        
        checkUserIsLogggedIn()
        
        var image = UIImage(named: "blogging")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image :image, style: .plain, target: self,action: #selector(handleMessage))
        
        firstTableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        
        
        
    }
    var messages = [Messages]()
    var messageDictionary = [String: Messages]()
    //EP11
    func observeUserMessage(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with :{(snapshot) in
            
            //找出訊息內容
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: {(snapshot) in
                
                //print(snapshot) 是每個toid在下一層的各訊息id
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId:messageId)
                
                
            },withCancel: nil)
            
        }, withCancel: nil)
        
    }
    private func fetchMessageWithMessageId(messageId: String){
        let messageReference = Database.database().reference().child("Message").child(messageId)
        
        messageReference.observeSingleEvent(of: .value, with: {(snapshot) in
            //print(snapshot)
            //ep11 13:00
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Messages()
                
                let data =  dictionary
                
                
                message.fromId = data["fromId"] as? String
                message.text = data["text"] as? String
                message.timestamp = data["timestamp"] as? NSNumber
                message.toId = data["toId"] as? String
                
                
                
                //加上後讓同一個人的訊息群組起來
                
                if case  let chatPartnerId = message.chatPartnerId() {
                    self.messageDictionary[chatPartnerId] = message
                    
                }
                self.attemptReloadofTable()
                
            }
            
        }, withCancel: nil)
    }
    private func attemptReloadofTable(){
        //overall:continuously setup a new timer to schedule with 0.1seconds and excute the reload
        //為以防太多的資料 在每次有新的訊息時就刪掉
        self.timer?.invalidate()
        
        self.timer =  Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        //print(data)
        
        //最後只會reload一次
        
        
    }
    var timer: Timer?
    @objc func handleReloadTable(){
        //我們不需要在每次有新訊息時就重新排列 只要在reload table時重排
        self.messages = Array(self.messageDictionary.values)
        //排列時間讓最新的在最上面
        self.messages.sort(by: { (message1,message2) -> Bool in
            return (message1.timestamp?.intValue)! > message2.timestamp!.intValue
            
            
        })
        //this will crash because of background thread
        DispatchQueue.main.async {
            self.firstTableView.reloadData()
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        
        //取出toId對應的user
        if case let id1 = message.chatPartnerId() {
            let ref = Database.database().reference().child("Friend/\(self.currentID!)").child(id1)
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    cell.textLabel?.text = dictionary["name"] as? String
                    
                    if let picture = dictionary["picture"] as? String{
                        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: picture)
                    }
                }
                
            })
        }
        
        cell.detailTextLabel?.text = message.text
        //如果沒加顯示的會是從1970到現在的秒數
        if let seconds = message.timestamp?.doubleValue{
            let timestampDate = NSDate(timeIntervalSince1970:seconds)
            //只要又印小時、分、秒
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            cell.timeLabel.text = dateFormatter.string(from: timestampDate as Date)
        }
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    //點擊後
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard case let chatPartnerId = message.chatPartnerId() else{
            return
        }
        let ref = Database.database().reference().child("Friend/\(self.currentID!)").child(chatPartnerId)
        ref.observe(.value, with: {(snapshot) in
            
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else{
                return
            }
            let friend = Friend()
            friend.id = chatPartnerId
            let data =  dictionary
            friend.name = data["name"] as? String
            friend.picture = data["picture"] as? String
            //跳轉到聊天頁
            self.showChatControllerForUser(friend:friend)
            
            
        }, withCancel: nil)
        
    }
    
    //The view controller that presented this view controller
    @objc func handleMessage(){
        let messageController = MessageController()
        //將messagecontroller的chatcontroller的屬性設給自己
        messageController.chatController = self
        //cancel的button按了返回
        let navContrller = UINavigationController(rootViewController: messageController)
        present(navContrller , animated:true,completion: nil)
        
        
        
    }
    func checkUserIsLogggedIn(){
        
        ref = Database.database().reference()
        if currentID != nil{
            Database.database().reference().child("Users").child(currentID!).observeSingleEvent(of: .value,with:{(snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.navigationItem.title = dictionary["name"] as? String
                    
                    
                }
                
            })
        }
        //兩個人傳的訊息 第三個人看不到
        messages.removeAll()
        messageDictionary.removeAll()
        firstTableView.reloadData()
        observeUserMessage()
        
        
    }
    
    
    @objc func showChatControllerForUser(friend:Friend){
        //()後面 for show chatcontroller
        let chatLogControl = ChatLogControl(collectionViewLayout: UICollectionViewFlowLayout())
        let navcontrller = UINavigationController(rootViewController: chatLogControl)
        present(navcontrller , animated:true,completion: nil)
        chatLogControl.friend = friend
        //navigationController?.pushViewController(chatLogControl, animated: true)
        
        
        
    }
    
    
    
}

