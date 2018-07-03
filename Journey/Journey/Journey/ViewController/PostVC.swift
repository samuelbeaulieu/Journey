//
//  PostVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-08.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit

class PostVC: UIViewController, UITextViewDelegate {
    
    //References
    @IBOutlet weak var postTextInput: UITextView!
    @IBOutlet weak var characterCount: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    //Variables

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let calendar = Calendar.current
        
        //Date
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        //Time
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        timeLabel.text = "\(day)-\(month)-\(year) at \(hour):\(minutes):\(seconds)"
        
        postTextInput.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = postTextInput.text.count + text.count - range.length
        //change the value of the label
        characterCount.text =  "\(newLength)/240"
        //you can save this value to a global var
        //myCounter = newLength
        //return true to allow the change, if you want to limit the number of characters in the text field use something like
        return newLength == 240 // To just allow up to 240 characters
        //return true
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
