//
//  LoginController.swift
//  ZooPower
//
//  Created by User8 on 2018/7/29.
//  Copyright © 2018年 com.fjuim. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn



class LoginController: UIViewController , GIDSignInUIDelegate {
    
    var ref : DatabaseReference?
    
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
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email , picture"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            
            //get user data to firebase
            let data = result as! NSDictionary
            let id = data["id"] , email = data["email"] , name = data["name"] , picture = data["picture"]
            let values = ["email" : email , "name" : name , "picture" : picture ]
            self.ref = Database.database().reference()
            self.ref?.child("Users").child(id as! String).setValue(values)
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let newPage = sb.instantiateViewController(withIdentifier: "UsersDataController") as? UsersDataController
            newPage?.facebookID = id as! String
            self.present(newPage!, animated: true, completion: nil)
        }
    }
    
    
    
    
    @IBAction func facebookLoginButton(_ sender: Any) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err ?? "")
                return
            }
            self.showEmailAddress()
        }
    }
    
    @IBAction func googleLoginButton(_ sender: Any) {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
}
