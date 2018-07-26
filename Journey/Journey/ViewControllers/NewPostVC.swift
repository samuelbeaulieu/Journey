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
import NYAlertViewController

class NewPostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postPhoto: UIImageView!
    @IBOutlet weak var postLocation: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postLocationPin: UIImageView!
    @IBOutlet weak var locationPhoto: UIImageView!
    @IBOutlet weak var timePhoto: UIImageView!
    
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
    //I only need to change the value here, everything else (labels, warnings, etc) is done automaticaly
    let limitLength = 85
    var limitText:Int = 0
    
    let postToolbar = UIToolbar()
    var charCount = UIBarButtonItem()
    var photoButton = UIBarButtonItem()
    var postPhotoButton = UIBarButtonItem()
    var flexibleSpace = UIBarButtonItem()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reference to the database for the post
        self.refPost = Database.database().reference().child("posts")
        
        postToolbar.sizeToFit()
        
        photoButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action: #selector(self.addPostPhoto))
        
        //creating flexible space
        flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // creating button
        charCount = UIBarButtonItem(title: "\(limitText)/\(limitLength)", style: .plain, target: nil, action: nil)
        
//        postPhotoButton = UIBarButtonItem(image: nil, style: .plain, target: nil, action: #selector(self.addPostPhoto))
        
        
        photoButton.tintColor = UIColor.darkGray
        charCount.tintColor = UIColor.darkGray
        
        
        postText.inputAccessoryView = postToolbar
        
        postToolbar.setItems([photoButton, flexibleSpace, charCount], animated: false) 
        
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
        
        if self.appDelegate.darkMode == true {
            UIApplication.shared.statusBarStyle = .lightContent
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]//user global variable
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
            self.navigationController?.navigationBar.tintColor = UIColor.white //user global variable
            
            view.backgroundColor = UIColor.darkGray
            locationPhoto.image = UIImage(named: "PinWhite")
            timePhoto.image = UIImage(named: "ClockWhite")
            postDate.textColor = UIColor.white
            postLocation.textColor = UIColor.white
            postText.textColor = UIColor.white
            postText.keyboardAppearance = .dark
            postToolbar.backgroundColor = UIColor.darkGray
            postToolbar.barTintColor = UIColor.darkGray
            photoButton.tintColor = UIColor.white
            charCount.tintColor = UIColor.white
            
        } else {
            UIApplication.shared.statusBarStyle = .default
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]//user global variable
            self.navigationController?.navigationBar.barStyle = .default
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.darkGray //user global variable
            
            view.backgroundColor = UIColor.white
            locationPhoto.image = UIImage(named: "Pin")
            timePhoto.image = UIImage(named: "Clock")
            postDate.textColor = UIColor.darkGray
            postLocation.textColor = UIColor.darkGray
            postText.textColor = UIColor.darkGray
            postText.keyboardAppearance = .light
            
            postToolbar.backgroundColor = UIColor.white
            postToolbar.barTintColor = UIColor.white
            photoButton.tintColor = UIColor.darkGray
            charCount.tintColor = UIColor.darkGray
            
        }
        
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
            break
        case .authorizedWhenInUse:
            print("User authorized location services when in Use. ")
            postLocation.isHidden = false
            postLocationPin.isHidden = false
            break
        case .authorizedAlways:
            print("User authorized location services set Always. ")
            postLocation.isHidden = false
            postLocationPin.isHidden = false
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            print("User can't enable location services. ")
            postLocation.isHidden = true
            postLocationPin.isHidden = true
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            print("User denied location.")
            postLocation.isHidden = true
            postLocationPin.isHidden = true
            let alertViewController = NYAlertViewController()
            
            if self.appDelegate.darkMode == true {
                alertViewController.titleColor = UIColor.white
                alertViewController.buttonColor = UIColor.white
                alertViewController.buttonTitleColor = UIColor.darkGray
                alertViewController.cancelButtonColor = UIColor.white
                alertViewController.cancelButtonTitleColor = UIColor.darkGray
                alertViewController.alertViewBackgroundColor = UIColor.darkGray
                //            alertViewController.buttonTitleColor = UIColor
            } else {
                
                alertViewController.buttonColor = UIColor.darkGray
                alertViewController.alertViewBackgroundColor = UIColor.white
            }
            // Set a title and message
            alertViewController.title = NSLocalizedString("Location Access Denied", comment: "noLocation")
            alertViewController.message = "If you change your mind and want to have your location, go to your phone settings and enable location access for Journey."
            
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
            break
        default:
            break
        }
    }
    
    //MARK: - Set the date label
    func setDate() {
        let dateFormatterToShow : DateFormatter = DateFormatter()
        dateFormatterToShow.dateFormat = "yyyy-MM-dd HH:mm:ss" //24h
//        dateFormatterToShow.dateFormat = "yyyy-MM-dd hh:mm:ss a" //12h AM/PM
        let date = Date()
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
            charCount.title = "\(newLength)/\(limitLength)"
        }
        
        //Change the color of the counter
        if limitText >= limitLength - 25 && limitText < limitLength - 10 {
            charCount.tintColor = UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.0)
        } else if limitText >= limitLength - 10 && limitText < limitLength {
            charCount.tintColor = UIColor(red:1.00, green:0.55, blue:0.00, alpha:1.0)
        } else if limitText == limitLength {
            charCount.tintColor = UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.0)
        } else {
            if self.appDelegate.darkMode == true {
                charCount.tintColor = UIColor.white
            } else {
                charCount.tintColor = UIColor.darkGray
            }
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
        if self.postText.text != "" && self.postPhoto.image != nil {
            //All good We can save our Object
            let id = self.refPost.childByAutoId().key
            self.post = Post(id: id,
                             text: self.postText.text!,
                             location: self.postLocation.text!,
                             date: self.postDate.text!,
                             image: self.postPhoto.image!
            )
            
            self.saveToDatabaseAndAddToArtistsArray(post: self.post!)
            if self.isInserting == true {
                //Handle new record here
                // self.appDelegate.artists.append(self.artist!)
                //Handle new record here
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        else{
            print("All Fields are required")
        }
    }

    func saveToDatabaseAndAddToArtistsArray(post:Post){
        //getting artist id
        let data = [
            "id": post.id,
            "text": post.text,
            "location": post.location,
            "date": post.date,
            "image": ""
            ] as [String : Any?]
        self.refPost.child((Auth.auth().currentUser?.uid)!).child(post.id!).setValue(data)
    
        saveImageToDatabase(image: (self.post?.image)!, post: post)
        print("Saved")
    
    }
    
    
    func saveImageToDatabase(image: UIImage, post:Post){
        let imageData = UIImageJPEGRepresentation(image, CGFloat(self.appDelegate.photoQuality))
        let storageRef = Storage.storage().reference().child((Auth.auth().currentUser?.uid)!).child("posts").child((self.post?.id)!)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) { (strMetaData, error) in
            if error == nil{
                print(strMetaData)
                print("Image Uploaded successfully")
                self.appDelegate.posts.append(post)
                self.dismiss(animated: true, completion: nil)
            }
            else{
                print("Error Uploading image: \(String(describing: error?.localizedDescription))")
            }
        }
        
    }
    
    //MARK: - Photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let pickedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            print("image was edited")
            newImage = pickedImage
            self.postPhoto.image = newImage
        } else if let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            print("image is original")
            newImage = pickedImage
            self.postPhoto.image = newImage
        } else {
            return
        }
//        profilePhoto.image = newImage
        customPhotoExist = true
        isPickingImage = false
        dismiss(animated: true)
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
