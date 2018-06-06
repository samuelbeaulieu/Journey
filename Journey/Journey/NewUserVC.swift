//
//  NewUserVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-05-28.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Photos

class NewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameInput: UITextField!
    
    var pictureExist:Bool = false
    
    let imagePicker = UIImagePickerController()
    
    
    var userCDData:[User] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = profilePicture.frame.width / 2
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor.lightGray.cgColor
        
        profilePicture.layer.masksToBounds = false
        profilePicture.clipsToBounds = true
        
        imagePicker.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            pictureExist = true
        } else {
            print("There was an error picking the image")
        }
    }
    
    @IBAction func editPhoto(_ sender: UIButton) {
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
                self.profilePicture.image = UIImage(named: "ImagePlaceholder")
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
    
    @IBAction func saveProfile(_ sender: Any) {
        saveToCoreData()
    }
    
    func saveToCoreData() {
        let context = self.appDelegate.persistentContainer.viewContext
        
        let userCD = User(context: context)
        userCD.email = self.appDelegate.email
        userCD.password = self.appDelegate.password
        userCD.name = self.nameInput.text//To be completed on the next view
        userCD.image = nil//To be completed on the next view
        userCD.facebook = false
        userCD.location = false//Default Value
        userCD.time = true//Default Value
        userCD.isNew = true
        userCD.creationDate = Date()
        
        self.appDelegate.saveContext()
        print("User : \n\tCreation Date : \(userCD.creationDate)\n\tEmail : \(userCD.email)\n\tPassword : \(userCD.password)\n\tName : \(userCD.name)\n\tImage : \(userCD.image)\n\tFacebook : \(userCD.facebook)\n\tLocation : \(userCD.location)\n\tTime : \(userCD.time)\n\tisNew : \(userCD.isNew)")
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
