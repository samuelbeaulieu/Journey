//
//  PostVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-08.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class PostVC: UIViewController {
    
    //References
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postTextInput: UITextView!
    @IBOutlet weak var characterCount: UILabel!
    @IBOutlet weak var postPhoto: UIImageView!
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    //Variables

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postPhoto.clipsToBounds = true
        postPhoto.layer.cornerRadius = 10
        addPhotoBtn.layer.cornerRadius = 10
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        
    }
    
    @IBAction func cancelPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    if picture != "placeholder"
    change btn text to edit picture
    */
}
