//
//  SettingsVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-06.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Photos

class SettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //References
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var editNameInput: UITextField!
    
    //Variables
    var pictureExist:Bool = false
    
    // Create a root reference
    let storageRef = Storage.storage().reference()
    
    let imagePicker = UIImagePickerController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Style for the profile picture
        profilePicture.layer.cornerRadius = profilePicture.frame.width / 2
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor.lightGray.cgColor
        profilePicture.layer.masksToBounds = false
        profilePicture.clipsToBounds = true
        
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            pictureExist = true
            // Data in memory
            let data = Data()
            let uploadData = UIImageJPEGRepresentation(profilePicture.image!, 0.1)
            
            // Create a reference to the file you want to upload
            let profilePictureRef = storageRef.child("\((Auth.auth().currentUser?.uid)!)/profilePicture.jpg")
            
            // Upload the file to the path "images/UID-profilePicture.jpg"
            profilePictureRef.putData(uploadData!, metadata: nil, completion: { (metadata, err) in
                if err != nil {
                    print(err!)
                    return
                }
            })
        } else {
            print("There was an error picking the image")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = editNameInput.text!
        changeRequest?.photoURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/journey-85487.appspot.com/o/anR9M1WtJ0aUB3DZ9hLsqsngAF63%2FprofilePicture.jpg?alt=media&token=3edda1b0-dfc4-40cf-9e1c-327788bfa39f")
//        changeRequest?.photoURL = URL(string: ("journey-85487.appspot.com/\((Auth.auth().currentUser?.uid)!)/profilePicture.jpg"))!
        changeRequest?.commitChanges { (error) in
            // ...
        }
//        print(Auth.auth().currentUser?.photoURL)
    }
    
    @IBAction func editProfilePicture(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takeNewPhotoButton = UIAlertAction(title: "Take a new photo", style: .default, handler: { (action) -> Void in
            print("Take a new photo button tapped")
            self.openCamera()
        })
        
        alertController.addAction(takeNewPhotoButton)
        
        let chooseExistingPhotoButton = UIAlertAction(title: "Choose from camera roll", style: .default, handler: { (action) -> Void in
            print("Choose from camera roll button tapped")
            self.openLibrary()
        })
        
        alertController.addAction(chooseExistingPhotoButton)
        
        if pictureExist == true {
            let  deleteButton = UIAlertAction(title: "Remove existing photo", style: .destructive, handler: { (action) -> Void in
                print("Remove existing photo button tapped")
                self.profilePicture.image = UIImage(named: "ProfilePhotoPicker")
                self.pictureExist = false
            })
            
            alertController.addAction(deleteButton)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openLibrary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func disconnectUser(_ sender: Any) {
        try! Auth.auth().signOut()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
