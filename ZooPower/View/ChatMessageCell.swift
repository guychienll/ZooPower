//
//  ChatMessageCellCollectionViewCell.swift
//  ZooPower
//
//  Created by 朱一心 on 2018/9/10.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    var chatLogControl: ChatLogControl?
    let textView: UITextView = {
    let tv = UITextView()
    tv.text = "smaple text for now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        //讓圖片上不能打字
        tv.isEditable = false
        
        return tv
    }()
    static let green =  UIColor(red: 130/255.0, green: 172/255.0, blue: 153/255.0, alpha: 1.0)
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = green
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        //沒有下面這行的話設置圓角就不會有作用
        view.layer.masksToBounds = true
        return view
    }()
    //有self要用lazy
    let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named:"icon_4")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
        
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        //點擊就觸發事件
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        
        return imageView
    }()
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer){
        let imageView = tapGesture.view as? UIImageView
        self.chatLogControl?.performZoomInForStartingImageView(staringImageView: imageView!)
    }
    var bubbleWidthAnchor: NSLayoutConstraint?
    var  bubbleViewRightAnchor: NSLayoutConstraint?
    var  bubbleViewLeftAnchor: NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        //x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        //x,y,w,h
        //-8 往左移
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
            
             bubbleViewRightAnchor?.isActive = true
         bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
       
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //x,y,w,h
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }
}
