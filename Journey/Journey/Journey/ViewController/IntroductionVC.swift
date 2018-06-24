//
//  IntroductionVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-08.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class IntroductionVC: UIViewController {

    //References
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    
    //Variables
    var userInfo = NSDictionary()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Style for the Facebook button
        //Creating the gradient for the Facebook button
        let gradient:CAGradientLayer = CAGradientLayer()
        let colorLeft = UIColor(red:0.24, green:0.35, blue:0.59, alpha:1.0).cgColor
        let colorRight = UIColor(red:0.37, green:0.51, blue:0.78, alpha:1.0).cgColor
        gradient.colors = [colorLeft, colorRight]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = facebookBtn.bounds
        gradient.cornerRadius = 25
        facebookBtn.layer.cornerRadius = 25
        facebookBtn.layer.addSublayer(gradient)
        
        //Style for the email button
        emailBtn.layer.cornerRadius = 25
        emailBtn.layer.borderWidth = 1
        emailBtn.layer.borderColor = UIColor.lightGray.cgColor
        emailBtn.layer.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.5).cgColor
        
        //Style for the navigation bar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    //Login with Facebook Button
    @IBAction func loginWithFacebook(_ sender: Any) {
        //Create the reference
        let loginManager = FBSDKLoginManager()
        //Ask for login and get some informations about the user
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if error != nil {
                //There's an error
                print(error?.localizedDescription)
            } else if result!.isCancelled {
                //User cancelled the login
                print("User cancelled login")
            } else {
                //Connection with Facebook successful, get user informations
                self.getUserInfo()
                self.useFirebaseLogin()
                //Close current view
                self.dismiss(animated: true, completion: {
                    //Reload the JournalTVC to show new informations(photo, name, posts, etc.)
                    JournalTVC().viewWillAppear(true)
                })
            }
        }
    }
    
    //This is called when the connection with Facebook is successful to try to login the user
    func useFirebaseLogin() {
        //Create a token to connect the user
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        //Sign in the user with Firebase using the token created above
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            if error != nil {
                //There's an error
                print("Could not login user \(error?.localizedDescription)")
            } else {
                //User logged in
                print("Email: \(result?.user.email!)")
            }
        }
    }
    
    //This is called when the connection with Facebook is successful to try to get more informations about the logged in user
    func getUserInfo() {
        //Ask for the following informations about the user
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, first_name, last_name, picture.type(large), gender, hometown, location"])
        //Send the request to get the informations
        request?.start(completionHandler: { (connection, result, error) in
            if error != nil {
                //There's an error
                print("Could not get user's informations : \(error?.localizedDescription)")
            } else {
                //Successful
                self.userInfo = result as! NSDictionary
                print("Fb results: \(self.userInfo)")
            }
        })
    }
    
    //This is to hide the navigation controller on the introduction views
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    //This is to show the navigation controller on other views
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
