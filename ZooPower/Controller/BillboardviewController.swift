//
//  ValueviewControlllwe.swift
//  ZooPower
//
//  Created by stacy on 2018/10/6.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

struct sortstruct{
    let billboard : Double!
    let name: String!
    let picture : String!
}

class BillboardviewController: UITableViewController{
    var post = [sortstruct]()
   
    var currentID = Auth.auth().currentUser?.uid
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationItem.backBarButtonItem?.backgroundImage(for: .normal, barMetrics: .default)
        
        let ref = Database.database().reference()
        ref.child("Users").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as?  [String : AnyObject]
            let billboard = value!["billboard"] as! Double
            let name = value!["name"] as! String
            let picture = value!["picture"] as! String
            
            self.post.insert(sortstruct(billboard: billboard, name: name, picture: picture), at: 0)
            self.post = self.post.sorted(by: {$0.billboard>$1.billboard})
            self.tableView.reloadData()
        })

        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "billboardcell")
        
        let billboard = cell?.viewWithTag(1) as! UILabel
        billboard.text = "\(String(describing: post[indexPath.row].billboard!) )"
        
        let name = cell?.viewWithTag(2) as! UILabel
        name.text = post[indexPath.row].name
        
        let picture = cell?.viewWithTag(3) as! UIImageView
        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.layer.borderWidth = 1
        picture.layer.masksToBounds = false
        picture.layer.borderColor = UIColor.black.cgColor
        picture.layer.cornerRadius = picture.frame.height/2
        picture.clipsToBounds = true
        
        let num = cell?.viewWithTag(4) as! UILabel
        var numpost = [String]()
        for i in 0...post.count{
            let i = i+1
            numpost.append(String(i))
        }
        num.text = numpost[indexPath.row]
        
        // get picture frim firebase: change String(url) to picture
        if let profileImageUrl = post[indexPath.row].picture{
        
            let url = NSURL(string: profileImageUrl)
            URLSession.shared.dataTask(with : url! as URL , completionHandler :{ (data, URLResponse, error) in
       
                if error != nil{
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    picture.image = UIImage(data: data!)
                }
            }).resume()
        }
        
        return cell!
    }
    
    @IBAction func okButton(sender: UIButton){

        dismiss(animated: true, completion: nil)
    }
    
}

