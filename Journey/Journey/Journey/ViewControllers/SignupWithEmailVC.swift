//
//  SignupWithEmailVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-06.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Photos

class SignupWithEmailVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //References
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var submitInfoBtn: UIButton!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var pic: UIButton!
    
    //Variables
    var keyboardActive:Bool = false
    
    
    //Variables
    var pictureExist:Bool = false
    
    // Create a root reference
    let storageRef = Storage.storage().reference()
    
    let imagePicker = UIImagePickerController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Style for the submitLoginBtn button
        submitInfoBtn.layer.cornerRadius = 25
        submitInfoBtn.layer.borderWidth = 1
        submitInfoBtn.layer.borderColor = UIColor.darkGray.cgColor
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Keyboard
        view.addGestureRecognizer(tap)
        
        if keyboardActive == false {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        
        imagePicker.delegate = self
    }
    
    @IBAction func submitInfo(_ sender: Any) {
        dismissKeyboard()
        let email: String!
        let password: String!
        if emailInput.text != "" && passwordInput.text != "" {
            email = self.emailInput.text
            password = self.passwordInput.text
        } else {
            print("Email and/or password are required!!")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error == nil {
                //Successful
                print("Registration Successful\nUID: \(authResult!.user.uid)\nEmail: \(authResult!.user.email)")
                
                self.dismiss(animated: true, completion: nil)
            } else {
                //There was errors
                print("Error creating user : \(error?.localizedDescription)")
            }
        }
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
    
    
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker.dismiss(animated: true, completion: nil)
            pictureExist = true
            // Data in memory
            let data = Data()
            let uploadData = UIImageJPEGRepresentation(image, 0.1)
            
            // Create a reference to the file you want to upload
            let profilePictureRef = storageRef.child("imhfftyf/profilePicture.jpg")
            
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
        changeRequest?.displayName = nameInput.text!
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
