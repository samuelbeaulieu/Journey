//
//  SettingsVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-08.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    //References
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profilePhotoShadow: UIImageView!
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var displayNameInput: UITextField!
    @IBOutlet weak var locationAccessSwitch: UISwitch!
    @IBOutlet weak var timeFormatSegment: UISegmentedControl!
    @IBOutlet weak var versionLabel: UILabel!
    
    //Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppVersion()
    }
    
    func getAppVersion() {
        //Get the version from the project
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            //Set the version label to the current version
            self.versionLabel.text = "Version \(version)"
        }
    }
    
    @IBAction func editProfilePhoto(_ sender: Any) {
        
    }
    
    @IBAction func disconnectUser(_ sender: Any) {
        
    }
}
