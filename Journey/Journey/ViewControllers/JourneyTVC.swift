//
//  JourneyTVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-07-04.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import NYAlertViewController

class JourneyTVC: UITableViewController {
    
    // MARK: - References
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var dayCountLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var photoCountLabel: UILabel!
    
    // MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var defaultDisplayName:String = "John Smith"
    
    var storageRef : StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Style for the navigation bar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Print user login status
        print("User Login Status: \(isUserLoggedIn())")
//        try! Auth.auth().signOut()
        //If not connected, go directly to the introduction view
        if isUserLoggedIn() == false {
            performSegue(withIdentifier: "JourneyToIntroduction", sender: self)
        }
        if isUserLoggedIn() == true {
            if Auth.auth().currentUser?.displayName == nil {
                //Create the default user profile
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = defaultDisplayName
                changeRequest?.commitChanges { (error) in
                    print(error?.localizedDescription)
                }
            } else {
                
                //Firebase Storage Reference
                self.storageRef = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid)!)/profilePhoto.jpg")
                
                let userDisplayName = Auth.auth().currentUser?.displayName
                displayNameLabel.text = userDisplayName!
                downloadPhoto()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        if appDelegate.newUser == true {
            let alertViewController = NYAlertViewController()
            // Set a title and message
            alertViewController.title = NSLocalizedString("Welcome to Journey!", comment: "welcomeNewUserTitle")
            alertViewController.message = NSLocalizedString("Journey doesn't require you to put your personnal informations. If you want a more personalized experience, you can edit them in the settings.", comment: "welcomeNewUserText")
            
            // Customize appearance as desired
            alertViewController.buttonCornerRadius = 20
            alertViewController.buttonColor = UIColor.darkGray
            
            alertViewController.transitionStyle = .slideFromTop
            alertViewController.swipeDismissalGestureEnabled = true
            alertViewController.backgroundTapDismissalGestureEnabled = true
            
            // Add alert actions
            let editLater = NYAlertAction(
                title: NSLocalizedString("Edit Later", comment: "editLater"),
                style: .default,
                handler: { (action: NYAlertAction!) -> Void in
                    self.dismiss(animated: true, completion: nil)
            }
            )
            alertViewController.addAction(editLater)
            
            let editNow = NYAlertAction(
                title: NSLocalizedString("Edit Now", comment: "editNow"),
                style: .default,
                handler: { (action: NYAlertAction!) -> Void in
                    self.dismiss(animated: true, completion: {
                        self.performSegue(withIdentifier: "journeyToSettings", sender: self)
                    })
            }
            )
            alertViewController.addAction(editNow)
            
            // Present the alert view controller
            self.present(alertViewController, animated: true, completion: nil)
            appDelegate.newUser = false
        }
    }
    
    //This is to hide the navigation controller on this view
    override func viewWillAppear(_ animated: Bool) {
        
        //This will hide the navigation bar on this view
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //This is to show the navigation controller on other views
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    func downloadPhoto() {
        // get the download URL
        storageRef.downloadURL { url, error in
            if let error = error {
                print("error downlaoding image :\(error.localizedDescription)")
            } else {
                do{
                    let imageData = try Data(contentsOf: url!)
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        self.profilePhoto.image = image
                    }
                }
                catch{
                    
                }
            }
        }
    }
    
    // MARK: - Firebase methods
    func isUserLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
