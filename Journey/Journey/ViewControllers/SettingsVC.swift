//
//  SettingsVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-07-04.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsVC: UIViewController {
    
    // MARK: - References
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var timeSegment: UISegmentedControl!
    @IBOutlet weak var disconnectBtn: UIButton!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    // MARK: - Variables
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppVersion()
        
    }
    
    @IBAction func disconnect(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
            dismiss(animated: true) {
                JourneyTVC().viewWillAppear(true)
            }
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func getAppVersion() {
        //Get the version from the project
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            //Set the version label to the current version
            self.appVersionLabel.text = "Version \(version)"
        }
    }
    
}
