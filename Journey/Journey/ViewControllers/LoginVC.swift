//
//  LoginVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-07-04.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

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
        
    }
}
