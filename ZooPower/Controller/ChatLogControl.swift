//
//  ChatLogControl.swift
//  ZooPower
//
//  Created by 朱一心 on 2018/8/23.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase

class ChatLogControl: UICollectionViewController ,UITextFieldDelegate ,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    let cellId = "cellId"
    //顯示你點入的好友名字再上面
   
    var friend: Friend?{
        didSet{
            navigationItem.title = friend?.name
            observeMessages()
        }
    }
   
    var messages = [Messages]()
    //抓取聊天訊息顯示出來
    func observeMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid , let toId = friend?.id else{
            return
        }
        
        //先找出user-messages每筆的id 再從Message裡面抓內容
        //只抓我點擊的人
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("Message").child(messageId)
            messageRef.observe(.value, with: { (snapshot) in
               
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else{
                    return
                }
                let message = Messages()
                let data =  dictionary
                message.fromId = data["fromId"] as? String
                message.text = data["text"] as? String
                message.timestamp = data["timestamp"] as? NSNumber
                message.toId = data["toId"] as? String
                message.imageUrl = data["imageUrl"] as? String
                message.imageHeight = data["imageHeight"] as? NSNumber
                message.imageWidth = data["imageWidth"] as? NSNumber
                //載入和點的人的聊天
               
                
                
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at:.bottom, animated: true)
                }
                
                
                
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    //將輸入的字和裡面關聯起來 就可以從handlesend取得輸入的
    //在屬性前放上 lazy ，可讓它延遲加載，就是只有在被使用的時候，它才會被加載
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let green =  UIColor(red: 173/255.0, green: 199/255.0, blue: 201/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.barTintColor = green
        
        var back = UIImage(named:"left-arrow")
        back = back?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: back,style: .done,target: self,action: #selector(handleCancel))
        collectionView?.contentInset = UIEdgeInsets(top: 8,left: 0,bottom: 8,right: 0)
        // collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0,left: 0,bottom: 50,right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        //讓keyboard可以上下滑
        collectionView?.keyboardDismissMode = .interactive
        
        //設置鍵盤
        setupKeyboardObservers()
    }
    lazy var inputContainerView: UIView? = {
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named:"image")
        
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUplpadTap)))
        containerView.addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 4).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //type: .system讓點擊後變色
        let sendButton = UIButton(type: .system)
        let sendButtonImage = UIImage(named: "send")
        sendButton.setBackgroundImage(sendButtonImage , for: UIControl.State.normal)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        //點擊時
        
        //self 把消息推送給自己
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        containerView.addSubview(self.inputTextField)
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo:uploadImageView.rightAnchor,constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return containerView
        
        
    }()
    @objc func handleUplpadTap(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = editedImage
            
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
            
        }
        //上面的只是用來指出你選的是哪張圖
        //此方法才是真正執行上傳的地方
        if let selectedImage = selectedImageFromPicker{
            
            uploadToFirebaseStorageUsingImage(image: selectedImage)
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage){
        
        //在storage建立一個資料夾
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2){
            ref.putData(uploadData, metadata: nil, completion: {(metadata,error)in
                if error != nil{
                    print("faild to upload image:",error)
                    return
                }
                ref.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    if let imageUrl = url?.absoluteString{
                        
                        self.sendMessageWithImageUrl(imageUrl: imageUrl,image: image)
                    }
                    
                    
                }
                )}
                
            )}
        
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    override var inputAccessoryView: UIView?{
        get{
            
            
            return  inputContainerView
        }
        
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
    }
    //讓keyboard點開後訊息可自動上滑
    @objc func handleKeyboardDidShow(){
        if messages.count > 0{
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
        
    }
    //if you don't remove may cause memory leak ->只要收一次鍵盤就呼叫一次 造成程式跑很慢
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    @objc func handleKeyboardWillShow(notification: NSNotification){
        //顯示keyboard的基本資料 ex高度
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        //move the input area up
        containerViewBottomAnchor?.constant = -keyboardFrame.height
        UIView.animate(withDuration: keyboardDuration){
            self.view.layoutIfNeeded()
        }
        
    }
    @objc func handleKeyboardWillHide(notification: NSNotification){
        
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        //move the input area up
        containerViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDuration){
            //if you want to animate constrainys all you need to do is call self view you needed after you modify constraint
            self.view.layoutIfNeeded()
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        //this cell referencr to chatlogcontrol
        cell.chatLogControl = self
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimateFramForText(text: text).width + 32
            cell.textView.isHidden = false
        }else if message.imageUrl != nil{
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        return cell
    }
    private func setupCell(cell: ChatMessageCell, message:Messages){
        
        //載入照片
        if let profileImageUrl = self.friend?.picture{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        
        //區分對話框是藍色或者灰色
        if message.fromId == Auth.auth().currentUser?.uid{
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.green
            cell.textView.textColor = UIColor.white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        }else{
            //outgoing gray
            cell.bubbleView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let messageImageUrl = message.imageUrl {
            
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }else{
            cell.messageImageView.isHidden = true
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text{
            height = estimateFramForText(text:text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue{
            //1->bubble 2->image
            // h1/w1 = h2/w2
            // solve for h1
            //h1 = h2/w2*w1
            height = CGFloat(imageHeight/imageWidth*200)
            
        }
        return CGSize(width: view.frame.width, height: height)
    }
    //讓bubble的高度符合字
    private func estimateFramForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    let now = Date()
    //按下send後做的事
    //傳送文字訊息
    @objc func handleSend(){
        let propertise = ["text":inputTextField.text!] as [String : AnyObject]
        sendMessageWithProperties(properties: propertise)
        
    }
    //傳送圖片訊息
    private func sendMessageWithImageUrl(imageUrl: String,image: UIImage){
        let properties = ["imageUrl": imageUrl,"imageWidth":image.size.width,"imageHeight": image.size.height] as [String : AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    private func sendMessageWithProperties(properties: [String: AnyObject]){
        let ref = Database.database().reference().child("Message")
        //為了讓聊天訊息可以有很多 不會只有一個一直重複更新 就是用成list的意思
        let childRef = ref.childByAutoId()
        //辨識是誰傳的、傳給誰、時間
        let toId = friend!.id!
        let fromId = Auth.auth().currentUser?.uid
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timestamp = Int(timeInterval)
        
        
        var values = ["toId":toId,"fromId":fromId ,"timestamp":timestamp] as [String : AnyObject]
        //key $0 value $1
        properties.forEach({values[$0] = $1})
        
        
        //為了要讓他統整 把fromid一樣的歸在同一個user-message
        childRef.updateChildValues(values){ (error,ref) in
            if error != nil{
                print(error)
                return
            }
            //訊息送出後就讓輸入框的訊息消失
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!).child(toId)
         
            
            let messageId = childRef.key!
            userMessagesRef.updateChildValues([messageId: 1])
            print(messageId)
            //讓接收者也可分類 給不一樣的人在user-messages會有不同的id
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId!)
           
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
        
    }
    //按下enter就跑這個方法 故呼叫handleSend()
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSend()
        return true
    }
    var staringFrame: CGRect?
    var blackbackground: UIView?
    var staringImageView: UIImageView?
    //my custom zoomging logic
    func performZoomInForStartingImageView(staringImageView: UIImageView){
        self.staringImageView = staringImageView
        self.staringImageView?.isHidden = true
        //訂出其四角形四角的位置
        staringFrame = staringImageView.superview?.convert(staringImageView.frame, to: nil)
        print(staringFrame)
        //畫出四角形
        let zoomingImageView = UIImageView(frame: staringFrame!)
        
        //將四角形圖案設置成圖片
        zoomingImageView.image = staringImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        if let keyWindow = UIApplication.shared.keyWindow{
            //讓底變成黑色
            blackbackground = UIView(frame: keyWindow.frame)
            blackbackground?.backgroundColor = UIColor.black
            blackbackground?.alpha = 0
            keyWindow.addSubview(blackbackground!)
            
            keyWindow.addSubview(zoomingImageView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseOut, animations: {
                //fade in 0 -> 1
                self.blackbackground?.alpha = 1
                self.inputContainerView?.alpha = 0
                //算出放大後的高度
                //h2/w2 = h1/w1
                //h2=h1/w1*w2
                let height = self.staringFrame!.height / self.staringFrame!.width * keyWindow.frame.width
                //點擊後紅色框框往上跑
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height:height)
                
                //往中間跑
                zoomingImageView.center = keyWindow.center
            },  completion: nil)
            
            
        }
        
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomingOutImageView = tapGesture.view{
            //need to animate back out to controller
            zoomingOutImageView.layer.cornerRadius = 16
            zoomingOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseOut, animations: {
                zoomingOutImageView.frame = self.staringFrame!
                //fade out
                self.blackbackground?.alpha = 0
                self.inputContainerView?.alpha = 1
            }, completion: {(completed: Bool) in
                zoomingOutImageView.removeFromSuperview()
                self.staringImageView?.isHidden = false
                
            })
            
            
            
        }
    }
}
