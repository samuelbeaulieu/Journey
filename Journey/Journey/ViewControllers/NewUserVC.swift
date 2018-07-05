//
//  NewUserVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-07-04.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class NewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    // MARK: - References
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    
    // MARK: - Variables
    var user:User?
    var isInserting:Bool = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isPickingPhoto:Bool = false
    var refUser:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refUser = Database.database().reference().child("users")
        
        //Style for the profile picture
        profilePhoto.layer.cornerRadius = profilePhoto.frame.width / 2
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        profilePhoto.layer.masksToBounds = false
        profilePhoto.clipsToBounds = true
        
        // Style for the startBtn button
        startBtn.layer.cornerRadius = 25
        startBtn.layer.borderWidth = 1
        startBtn.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func startJourney(_ sender: Any) {
        if self.nameInput.text != "" {
            //All good We can save our Object
            let id = self.refUser.childByAutoId().key
            self.user = User(id: id, name: self.nameInput.text!, image: profilePhoto.image)
            if self.isInserting == true {
                //Handle new record here
                // self.appDelegate.artists.append(self.artist!)
                //Handle new record here
                self.saveToDatabaseAndAddToArtistsArray(user: self.user!)
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        else{
            print("All Fields are required")
        }
        self.dismiss(animated: true, completion: nil)
    }

    
    
    @IBAction func skipProfileSetup(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveToDatabaseAndAddToArtistsArray(user:User){
        //getting artist id
        let data = [
            "id": user.id,
            "name": user.name,
            "image": ""
            ] as [String : Any?]
        self.refUser.child((Auth.auth().currentUser?.uid)!).child(user.id!).setValue(data)
        
        saveImageToDatabase(image: (self.user?.image)!, user: user)
    }
    
    func saveImageToDatabase(image: UIImage, user:User) {
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let storageRef = Storage.storage().reference().child("images").child((self.user?.name)!)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) { (strMetaData, error) in
            if error == nil {
                print("Image Uploaded Succesfully")
                self.appDelegate.users.append(user)
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error Uploading Image : \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
}
