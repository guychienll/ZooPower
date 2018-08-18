//
//  LoginController.swift
//  ZooPower
//
//  Created by User8 on 2018/7/29.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn



class LoginController: UIViewController , GIDSignInUIDelegate {
    
    var ref : DatabaseReference?
    var currentID : String?
    var data : NSDictionary?
    var id : Any?
    var name : Any?
    var email : Any?
    var picture : Any?
    var values : [String : Any]?
    
    @IBOutlet weak var facebookLoginButton: UIButton!{
        didSet{
            facebookLoginButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var googleLoginButton: UIButton!{
        didSet{
            googleLoginButton.layer.cornerRadius = 10
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func showEmailAddress(){
        
        // Firebase Auth
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            print("Successfully logged in with our user: ", user ?? "")
            self.currentID = Auth.auth().currentUser?.uid
            self.ref = Database.database().reference()
            self.ref?.child("Users").child(self.currentID!).updateChildValues(self.values as! [AnyHashable : Any])
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let usersDataController = sb.instantiateViewController(withIdentifier: "UsersDataController") as? UsersDataController
            usersDataController?.facebookID = self.id as! String
            self.present(usersDataController!, animated: true, completion: nil)
            
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email , picture"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            
            //get user data to firebase
            self.data = result as? NSDictionary
            self.id = self.data!["id"]
            self.email = self.data!["email"]
            self.name = self.data!["name"]
            self.picture = self.data!["picture"]
            self.values = ["email" : self.email , "name" : self.name , "picture" : self.picture ]
            
        }
    }
    
    
    
    
    @IBAction func facebookLoginButton(_ sender: Any) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err ?? "")
                return
            }
            self.showEmailAddress()
            UserDefaults.standard.set(1, forKey: "checkLogIn")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func googleLoginButton(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
        UserDefaults.standard.set(1, forKey: "checkLogIn")
        UserDefaults.standard.synchronize()
    }
}
