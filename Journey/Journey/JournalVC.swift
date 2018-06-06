//
//  JournalVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-05-25.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class JournalVC: UIViewController {
    @IBOutlet weak var navigationBarShadow: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Creating the gradient for the Facebook button
        let gradient:CAGradientLayer = CAGradientLayer()
        let colorTop = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0).cgColor
        let colorBottom = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0).cgColor
        
        //Style for the Facebook button
        gradient.colors = [colorTop, colorBottom]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = navigationBarShadow.bounds
        navigationBarShadow.layer.addSublayer(gradient)
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
