//
//  LoginWithEmailVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-08.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginWithEmailVC: UIViewController {

    //References
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var submitLoginBtn: UIButton!
    
    //Variables
    var keyboardActive:Bool = false
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Style for the submitLoginBtn button
        submitLoginBtn.layer.cornerRadius = 25
        submitLoginBtn.layer.borderWidth = 1
        submitLoginBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        //Keyboard
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        if keyboardActive == false {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func autoFillTextFields(_ sender: Any) {
        emailInput.text = "me@samuelbeaulieu.com"
        passwordInput.text = "ThisIsASecurePassword"
//        submitLogin(self)
    }
    
    @IBAction func submitLogin(_ sender: Any) {
        dismissKeyboard()
        let email: String!
        let password: String!
        if emailInput.text != "" && passwordInput.text != "" {
            email = self.emailInput.text
            password = self.passwordInput.text
            Auth.auth().signIn(withEmail: email, password: password, completion: { (authResult, error) in
                if error == nil {
                    //Successful
                    print("Login Successful")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    //User account doesn't exist
                    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                        if error == nil {
                            //Successful
                            print("Registration Successful")
                            self.performSegue(withIdentifier: "LoginWithEmailToNewUser", sender: self)
                        } else {
                            //There was errors
                            print("Error creating user : \(error?.localizedDescription)")
                        }
                    }
                }
            })
        } else {
            print("Email and password are required!")
            return
        }
    }
    
    // MARK: - Keyboard
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        keyboardActive = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardActive == false {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardSize.height
            }
            keyboardActive = true
        }
    }
    
    //Move the view to previous state after keyboard close
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
}
