//
//  NewPostVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-07-04.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import Photos

class NewPostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var postText: UITextView!
    
    // MARK: - Variables
    var customPhotoExist:Bool = false
    var photoDownloaded:Bool = false
    var keyboardActive:Bool = false
    var isPickingImage = false
    
    let imagePicker = UIImagePickerController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var storageRef : StorageReference!
    
    let limitLength = 240
    var limitText:Int = 0
    
    var charCount = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let postToolbar = UIToolbar()
        postToolbar.sizeToFit()
        
        let photoButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action: #selector(self.addPostPhoto))
        
        //creating flexible space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // creating button
        charCount = UIBarButtonItem(title: "\(limitText)/240", style: .plain, target: nil, action: nil)
        
        photoButton.tintColor = UIColor.darkGray
        charCount.tintColor = UIColor.darkGray
        
        postToolbar.setItems([photoButton, flexibleSpace, charCount], animated: false)
        
        postText.inputAccessoryView = postToolbar
        
        //Delegate
        imagePicker.delegate = self
        postText.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        postText.becomeFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //Calculate the number of character in the textView
        let newLength = postText.text.count + text.count - range.length
        
        //change the value of the label
        if newLength <= limitLength {
            limitText = newLength
            charCount.title = "\(newLength)/240"
        }
        
        //Change the color of the counter
        if limitText >= 200 && limitText < 220 {
            charCount.tintColor = UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.0)
        } else if limitText >= 220 && limitText < 240 {
            charCount.tintColor = UIColor(red:1.00, green:0.55, blue:0.00, alpha:1.0)
        } else if limitText == 240 {
            charCount.tintColor = UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.0)
        } else {
            charCount.tintColor = UIColor.darkGray
        }
        
        //Block the maximum character to the limitLength
        return newLength <= limitLength
    }
    
    @IBAction func cancelNewPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveNewPost(_ sender: Any) {
        
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    // MARK : - Photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let pickedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            print("image was edited")
            newImage = pickedImage
            uploadProfilePhoto(image: newImage)
        } else if let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            print("image is original")
            newImage = pickedImage
            uploadProfilePhoto(image: newImage)
        } else {
            return
        }
//        profilePhoto.image = newImage
        customPhotoExist = true
        isPickingImage = false
        dismiss(animated: true)
    }
    
    func uploadProfilePhoto(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        
        let storageRef = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid)!)/profilePhoto.jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) { (strMetaData, error) in
            if error == nil{
                print("Image Uploaded successfully")
                self.dismiss(animated: true, completion: nil)
            }
            else{
                print("Error Uploading image: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @objc func addPostPhoto() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takeNewPhotoButton = UIAlertAction(title: NSLocalizedString("Take a new photo", comment: "takePhoto"), style: .default, handler: { (action) -> Void in
            print("Take a new photo button tapped")
            self.openCamera()
        })
        
        alertController.addAction(takeNewPhotoButton)
        
        let chooseExistingPhotoButton = UIAlertAction(title: NSLocalizedString("Choose from camera roll", comment: "cameraRoll"), style: .default, handler: { (action) -> Void in
            print("Choose from camera roll button tapped")
            self.openLibrary()
        })
        
        alertController.addAction(chooseExistingPhotoButton)
        
        if customPhotoExist == true {
            let  deleteButton = UIAlertAction(title: NSLocalizedString("Remove existing photo", comment: "removePhoto"), style: .destructive, handler: { (action) -> Void in
                print("Remove existing photo button tapped")
                self.customPhotoExist = false
            })
            
            alertController.addAction(deleteButton)
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func openCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = UIImagePickerControllerSourceType.camera
        cameraPicker.allowsEditing = true
        self.present(cameraPicker, animated: true, completion: nil)
    }
    
    func openLibrary() {
        let libraryPicker = UIImagePickerController()
        libraryPicker.allowsEditing = true
        libraryPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        libraryPicker.delegate = self
        present(libraryPicker, animated: true)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPickingImage = false
        dismiss(animated: true)
    }
    
}
