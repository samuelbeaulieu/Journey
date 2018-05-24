//
//  ViewController.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-05-24.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //References to the login buttons
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    
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
        gradient.frame = facebookBtn.bounds
        gradient.cornerRadius = 25
        facebookBtn.layer.cornerRadius = 25
        facebookBtn.layer.addSublayer(gradient)
        
        //Style for the email button
        emailBtn.layer.cornerRadius = 25
        emailBtn.layer.borderWidth = 1
        emailBtn.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

