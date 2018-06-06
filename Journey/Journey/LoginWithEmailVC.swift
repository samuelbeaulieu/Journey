//
//  LoginWithEmailVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-05-25.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import CoreData

class LoginWithEmailVC: UIViewController {
    //References
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var emailAddressInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    var emailVerification:Bool = false
    var passwordVerification:Bool = false
    
    var keyboardActive:Bool = false
    
    var userCDData:[User] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Style for the continue button
        continueButton.layer.cornerRadius = 25
        continueButton.layer.borderWidth = 1
        continueButton.layer.borderColor = UIColor.lightGray.cgColor
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        //Keyboard
        view.addGestureRecognizer(tap)
        
        if keyboardActive == false {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func loginContinue(_ sender: Any) {
        dismissKeyboard()
        performSegue(withIdentifier: "loginWithEmailToNewUser", sender: self)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
