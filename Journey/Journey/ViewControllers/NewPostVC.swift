//
//  NewPostVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-07-04.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class NewPostVC: UIViewController {

    @IBOutlet weak var postText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let postToolbar = UIToolbar()
        postToolbar.sizeToFit()
        
        let photoButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action: #selector(self.addPostPhoto))
        
        //creating flexible space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // creating button
        let addButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(postCharacterCount))
        
        photoButton.tintColor = UIColor.darkGray
        
        postToolbar.setItems([photoButton, flexibleSpace, addButton], animated: false)
        
        postText.inputAccessoryView = postToolbar
    }
    
    @IBAction func cancelNewPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveNewPost(_ sender: Any) {
        
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func addPostPhoto() {
        print("camera")
    }
    @objc func postCharacterCount() {
        print("word")
    }
    
}
