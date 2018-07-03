//
//  NewUserVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-11.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Photos

class NewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //References
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profilePhotoShadow: UIImageView!
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var displayNameInput: UITextField!
    @IBOutlet weak var startJourneyBtn: UIButton!
    
    //Variables
    var pictureExist:Bool = false
    var keyboardActive:Bool = false
    
    let imagePicker = UIImagePickerController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var storageRef : StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Style for the profile picture
        profilePhoto.layer.cornerRadius = profilePhoto.frame.width / 2
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        profilePhoto.layer.masksToBounds = false
        profilePhoto.clipsToBounds = true
        
        //Firebase Storage Reference
        self.storageRef = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid)!)/profilePhoto.jpg")
        
        //Keyboard
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        if keyboardActive == false {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //Profile Photo
        imagePicker.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayNameInput.text!
        //        changeRequest?.photoURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/journey-85487.appspot.com/o/anR9M1WtJ0aUB3DZ9hLsqsngAF63%2FprofilePicture.jpg?alt=media&token=3edda1b0-dfc4-40cf-9e1c-327788bfa39f")
        //        changeRequest?.photoURL = URL(string: ("journey-85487.appspot.com/\((Auth.auth().currentUser?.uid)!)/profilePicture.jpg"))!
        changeRequest?.commitChanges { (error) in
            print(error?.localizedDescription)
        }
        //        print(Auth.auth().currentUser?.photoURL)
    }
    
    @IBAction func startJourney(_ sender: Any) {
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Keyboard
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        keyboardActive = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardActive == false {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardSize.height
            }
            keyboardActive = true
        }
    }
    
    //Move the view to previous state after keyboard close
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    // MARK : - Photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePhoto.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            pictureExist = true
            // Data in memory
            let data = UIImageJPEGRepresentation(image, 0.8)
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = storageRef.putData(data!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                self.storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                }
            }
        } else {
            print("There was an error picking the image")
        }
    }
    
    func uploadProfilePhoto(image: UIImage) {
        
        // Data in memory
        let data = Data()
        let uploadData = UIImageJPEGRepresentation(image, 0.1)
        
        // Create a reference to the file you want to upload
        let profilePhotoRef = storageRef
        
        // Upload the file to the path "images/UID-profilePicture.jpg"
        profilePhotoRef?.putData(uploadData!, metadata: nil, completion: { (metadata, err) in
            if err != nil {
                print(err!)
                return
            }
        })
    }
    
    @IBAction func editProfilePhoto(_ sender: Any) {
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
}
