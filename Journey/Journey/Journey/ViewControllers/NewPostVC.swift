//
//  NewPostVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-06.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class NewPostVC: UIViewController {

    @IBOutlet weak var photoPicker: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoPicker.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelNewPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
