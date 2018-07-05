//
//  IntroductionVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-07-04.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class IntroductionVC: UIViewController {
    
    // MARK: - References
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    
    // MARK: - Variables
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Style for the Facebook button
        // Creating the gradient for the Facebook button
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
        
        // Style for the email button
        emailBtn.layer.cornerRadius = 25
        emailBtn.layer.borderWidth = 1
        emailBtn.layer.borderColor = UIColor.lightGray.cgColor
        emailBtn.layer.backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.5).cgColor
        
        // Style for the navigation bar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    // MARK: - Facebook Login
    @IBAction func loginWithFacebook(_ sender: Any) {
        
    }
    
    // MARK: - Navigation Controller Style
    // This is to hide the navigation controller on the introduction views
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    // This is to show the navigation controller on other views
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
