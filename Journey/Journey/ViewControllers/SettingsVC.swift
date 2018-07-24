//
//  SettingsVC.swift
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
import NYAlertViewController
import Kingfisher
import FBSDKLoginKit

class SettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - References
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var timeSegment: UISegmentedControl!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    // MARK: - Variables
    var customPhotoExist:Bool = false
    var photoDownloaded:Bool = false
    var keyboardActive:Bool = false
    var isPickingImage = false
    var userInfo = NSDictionary()
    
    let imagePicker = UIImagePickerController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var storageRef : StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppVersion()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Logout"), style: .plain, target: self, action: #selector(disconnect))
        
        //Firebase Storage Reference
        self.storageRef = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid)!)/profilePhoto.jpg")
        
        //Style for the profile picture
        profilePhoto.layer.cornerRadius = profilePhoto.frame.width / 2
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        profilePhoto.layer.masksToBounds = false
        profilePhoto.clipsToBounds = true
        
        //Profile Photo
        imagePicker.delegate = self
        nameInput.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if photoDownloaded == false {
            if let providerData = Auth.auth().currentUser?.providerData {
                for userInfo in providerData {
                    switch userInfo.providerID {
                    case "facebook.com":
                        print("user is signed in with facebook")
                        getUserInfo()
                        nameInput.isEnabled = false
                        profilePhoto.isUserInteractionEnabled = false
                        let alertViewController = NYAlertViewController()
                        // Set a title and message
                        alertViewController.title = NSLocalizedString("Facebook user", comment: "facebookPhoto")
                        alertViewController.message = "If you want to edit your profile informations, edit them directly on Facebook and Journey will load the new informations as soon as it can."
                        
                        // Customize appearance as desired
                        alertViewController.buttonCornerRadius = 20
                        alertViewController.buttonColor = UIColor.darkGray
                        //        alertViewController.cancelButtonColor
                        
                        alertViewController.transitionStyle = .slideFromTop
                        alertViewController.swipeDismissalGestureEnabled = true
                        alertViewController.backgroundTapDismissalGestureEnabled = true
                        
                        // Add alert actions
                        let editLater = NYAlertAction(
                            title: NSLocalizedString("Okay", comment: "okay"),
                            style: .cancel,
                            handler: { (action: NYAlertAction!) -> Void in
                                self.dismiss(animated: true, completion: nil)
                        }
                        )
                        alertViewController.addAction(editLater)
                        
                        // Present the alert view controller
                        self.present(alertViewController, animated: true, completion: nil)
                    default:
                        print("user is signed in with \(userInfo.providerID)")
                        //Firebase Storage Reference
                        self.storageRef = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid)!)/profilePhoto.jpg")
                        downloadPhoto()
                    }
                }
            }
            photoDownloaded = true
        }
        
        let userDisplayName = Auth.auth().currentUser?.displayName
        nameInput.text = userDisplayName!
    }
    
    //MARK: - Facebook
    //This is called when the connection with Facebook is successful to try to get more informations about the logged in user
    func getUserInfo() {
        let deviceScale = UIScreen.main.bounds
        let width = Int(deviceScale.width)
        let height = Int(deviceScale.height)
        //        let parameters = ["fields": "first_name, last_name, picture.width(\(width)).height(\(height))"]
        //Ask for the following informations about the user
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, picture.width(\(width))"])
        //Send the request to get the informations
        request?.start(completionHandler: { (connection, result, error) in
            if error != nil {
                //There's an error
                print("Could not get user's informations : \(error?.localizedDescription)")
            } else {
                //Successful
                self.userInfo = result as! NSDictionary
                print("Fb results: \(self.userInfo)")
                
                if FBSDKAccessToken.current() != nil {
                    
                    let userID = FBSDKAccessToken.current().userID
                    
                    if(userID != nil) //should be != nil
                    {
                        print(userID)
                    }
                    if let imageURL = ((self.userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                        //Download image from imageURL
                        
                        //                    let dictionary = result as? NSDictionary
                        //                    let data = dictionary?.object(forKey: "data")
                        //                    let urlPic = (data?.object(forKey: "url"))! as! String
                        
                        let photoURL = URL(string: imageURL)
                        
                        self.profilePhoto.kf.setImage(with: photoURL)
                    }
                }else{
                    
                }
            }
        })
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
        profilePhoto.image = newImage
        customPhotoExist = true
        isPickingImage = false
        dismiss(animated: true)
    }
    
    func downloadPhoto() {
        // get the download URL
        storageRef.downloadURL { url, error in
            if let error = error {
                print("error downlaoding image :\(error.localizedDescription)")
                self.profilePhoto.image = UIImage(named: "Profile")
            } else {
                self.profilePhoto.kf.setImage(with: url)
            }
        }
    }
    
    func uploadProfilePhoto(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let storageRef = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid)!)/profilePhoto.jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) { (strMetaData, error) in
            if error == nil{
                print("Image Uploaded successfully")
                self.downloadPhoto()
                self.dismiss(animated: true, completion: nil)
            }
            else{
                print("Error Uploading image: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func editProfilePhoto(_ sender: Any) {
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    print("user is signed in with facebook")
                default:
                    print("user is signed in with \(userInfo.providerID)")
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
                    
                    let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
                        print("Cancel button tapped")
                    })
                    alertController.addAction(cancelButton)
                    
                    self.navigationController!.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
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
    
    @IBAction func changeLocationAccess(_ sender: Any) {
        
    }
    
    @objc func disconnect() {
        let alertViewController = NYAlertViewController()
        // Set a title and message
        alertViewController.title = NSLocalizedString("Log out of ", comment: "logOutJourney") + (Auth.auth().currentUser?.displayName)! + "?"
        alertViewController.message = ""
        
        // Customize appearance as desired
        alertViewController.buttonCornerRadius = 20
        alertViewController.buttonColor = UIColor.darkGray
//        alertViewController.cancelButtonColor
        
        alertViewController.transitionStyle = .slideFromTop
        alertViewController.swipeDismissalGestureEnabled = true
        alertViewController.backgroundTapDismissalGestureEnabled = true
        
        // Add alert actions
        let editLater = NYAlertAction(
            title: NSLocalizedString("Cancel", comment: "cancel"),
            style: .cancel,
            handler: { (action: NYAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
        }
        )
        alertViewController.addAction(editLater)
        
        let editNow = NYAlertAction(
            title: NSLocalizedString("Log Out", comment: "logOuts"),
            style: .default,
            handler: { (action: NYAlertAction!) -> Void in
                self.dismiss(animated: true, completion: {
                    do {
                        try Auth.auth().signOut()
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true) {
                            JourneyTVC().viewDidAppear(true)
                        }
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                })
            }
        )
        alertViewController.addAction(editNow)
        
        // Present the alert view controller
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    //Hide the keyboard when 'return' key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //Change the displayName on firebase
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = nameInput.text!
        changeRequest?.commitChanges { (error) in
            print(error?.localizedDescription)
        }
        return true
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
        //Change the displayName on firebase
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = nameInput.text!
        changeRequest?.commitChanges { (error) in
            print(error?.localizedDescription)
        }
    }
    
    func getAppVersion() {
        //Get the version from the project
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            //Set the version label to the current version
            self.appVersionLabel.text = NSLocalizedString("Version", comment: "appVersion") + " \(version)"
        }
    }
    
    @IBAction func linkToMyPortfolio(_ sender: Any) {
        UIApplication.shared.open(URL(string : "https://www.samuelbeaulieu.com")!, options: [:], completionHandler: { (status) in

        })
    }
}
