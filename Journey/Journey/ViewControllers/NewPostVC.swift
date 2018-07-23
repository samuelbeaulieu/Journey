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
import FirebaseDatabase
import Photos
import CoreLocation

class NewPostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postPhoto: UIImageView!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postLocationPin: UIImageView!
    
    // MARK: - Variables
    var customPhotoExist:Bool = false
    var photoDownloaded:Bool = false
    var keyboardActive:Bool = false
    
    let imagePicker = UIImagePickerController()
    var storageRef : StorageReference!
    
    //Post
    var post : Post?
    var isInserting : Bool = false
    var isPickingImage = false
    
    var refPost : DatabaseReference!
    
    var locationManager = CLLocationManager()
    
    //Character count
    let limitLength = 240
    var limitText:Int = 0
    var charCount = UIBarButtonItem()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reference to the database for the post
        self.refPost = Database.database().reference().child("posts")
        
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
        
        setDate()
        
        //Delegate
        imagePicker.delegate = self
        postText.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Make the keyboard show automatically
        postText.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callLocationServices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
    }
    
    //MARK: - Get user location
    func callLocationServices(){
        //Setting this view controller to be responsible of Managing the locations
        self.locationManager.delegate = self
        //We want the best accuracy
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //We want location service to on all the time
        //self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        //Check if user authorized the use of location services
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("here")
        let currentLocation:CLLocation = locations[0] as CLLocation
        //We need to make sure we have a valid Location
        if currentLocation.verticalAccuracy < 0 {
            return
        }
        if currentLocation.horizontalAccuracy < 0 {
            return
        }
        print("here")
        print(currentLocation)
        self.locationManager.stopUpdatingLocation()
//        self.postLocation.text = "\(currentLocation.coordinate.latitude) || \(currentLocation.coordinate.longitude)"
        
        CLGeocoder().reverseGeocodeLocation(currentLocation) { (placemark, error) in
            if error != nil {
                print ("THERE WAS AN ERROR")
            } else {
                if let place = placemark?[0] {
                    if let checker = place.subThoroughfare {
                        self.postLocation.text = "\(place.locality!), \(place.administrativeArea!)"
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("We are unable to determine your location services authorization. ")
            postLocation.isHidden = true
            postLocationPin.isHidden = true
            appDelegate.locationAccess = false
            break
        case .authorizedWhenInUse:
            print("User authorized location services when in Use. ")
            postLocation.isHidden = false
            postLocationPin.isHidden = false
            appDelegate.locationAccess = true
            break
        case .authorizedAlways:
            print("User authorized location services set Always. ")
            postLocation.isHidden = false
            postLocationPin.isHidden = false
            appDelegate.locationAccess = true
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            print("User can't enable location services. ")
            postLocation.isHidden = true
            postLocationPin.isHidden = true
            appDelegate.locationAccess = false
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            print("User denied location.")
            postLocation.isHidden = true
            postLocationPin.isHidden = true
            appDelegate.locationAccess = false
            break
        default:
            break
        }
    }
    
    //MARK: - Set the date label
    func setDate() {
        let dateFormatterToSave : DateFormatter = DateFormatter()
        let dateFormatterToShow : DateFormatter = DateFormatter()
        dateFormatterToSave.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatterToShow.dateFormat = "HH:mm:ss"
        let date = Date()
        let dateStringToSave = dateFormatterToSave.string(from: date)
        let dateStringToShow = dateFormatterToShow.string(from: date)
        let interval = date.timeIntervalSince1970
        
        postDate.text = "\(dateStringToShow)"
    }
    
    //MARK: - Character Count
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
    
    //MARK: - Cancel post
    @IBAction func cancelNewPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Save post
    @IBAction func saveNewPost(_ sender: Any) {
        if (self.postText.text != "" && self.postPhoto.image != nil) {
            
        }
    }
    
    //MARK: - Hide Keyboard
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    //MARK: - Photo
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
        
        let storageRef = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid)!)/posts/photo.jpg")
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
