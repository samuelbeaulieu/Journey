//
//  IntroductionVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-05-25.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class IntroductionVC: UIViewController {
    //References
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Creating the gradient for the Facebook button
        let gradient:CAGradientLayer = CAGradientLayer()
        let colorLeft = UIColor(red:0.24, green:0.35, blue:0.59, alpha:1.0).cgColor
        let colorRight = UIColor(red:0.37, green:0.51, blue:0.78, alpha:1.0).cgColor
        
        //Style for the Facebook button
        gradient.colors = [colorLeft, colorRight]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = facebookButton.bounds
        gradient.cornerRadius = 25
        facebookButton.layer.cornerRadius = 25
        facebookButton.layer.addSublayer(gradient)
        
        //Style for the email button
        emailButton.layer.cornerRadius = 25
        emailButton.layer.borderWidth = 1
        emailButton.layer.borderColor = UIColor.lightGray.cgColor
        
        //Style for the navigation bar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Links for the code I needed help with
/*
 1. Hide the navigation controller on the introduction view & Show the navigation controller on the Login With Email view. https://stackoverflow.com/a/45587555
 2. Remove the bottom border on the navigation controller. https://stackoverflow.com/a/38745391
 3.
 4.
 5.
 6.
 7.
 8.
 9.
 10.
 */
