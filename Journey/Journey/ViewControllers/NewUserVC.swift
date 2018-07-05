//
//  NewUserVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-07-04.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class NewUserVC: UIViewController {

    // MARK: - References
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    
    // MARK: - Variables
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Style for the profile picture
        profilePhoto.layer.cornerRadius = profilePhoto.frame.width / 2
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        profilePhoto.layer.masksToBounds = false
        profilePhoto.clipsToBounds = true
        
        // Style for the startBtn button
        startBtn.layer.cornerRadius = 25
        startBtn.layer.borderWidth = 1
        startBtn.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func startJourney(_ sender: Any) {
        
    }
    
    @IBAction func editProfilePhoto(_ sender: Any) {
        
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
}
