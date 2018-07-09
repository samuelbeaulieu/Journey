//
//  LoginVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-07-04.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginVC: UIViewController {

    // MARK: - References
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    // MARK: - Variables
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Style for the submitBtn button
        submitBtn.layer.cornerRadius = 25
        submitBtn.layer.borderWidth = 1
        submitBtn.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func autoFill(_ sender: Any) {
        emailInput.text = "me@samuelbeaulieu.com"
        passwordInput.text = "ThisIsASecurePassword"
//        submitInformations(self)
    }
    
    @IBAction func submitInformations(_ sender: Any) {
        hideKeyboard(self)
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
                            self.dismiss(animated: true, completion: {
                                JourneyTVC().userIsNew()
                            })
                        } else {
                            //There was errors
                            print("Error creating user : \(String(describing: error?.localizedDescription))")
                        }
                    }
                }
            })
        } else {
            print("Email and password are required!")
            return
        }
    }
    
    //MARK: - HIDE KEYBOARD
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
}
