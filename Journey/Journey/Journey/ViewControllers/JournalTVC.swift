//
//  JournalTVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-06.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Nuke

class JournalTVC: UITableViewController {

    @IBOutlet weak var navigationBarShadow: UIView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    // Get a reference to the storage service using the default Firebase App
//    let storage = Storage.storage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        try! Auth.auth().signOut()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //Creating the gradient for the navigationBarShadow view
        let gradient:CAGradientLayer = CAGradientLayer()
        let colorTop = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0).cgColor
        let colorBottom = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.0).cgColor
        
        //Style for the navigationBarShadow view
        gradient.colors = [colorTop, colorBottom]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = navigationBarShadow.bounds
        navigationBarShadow.layer.addSublayer(gradient)
        
        //Style for the navigation bar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        firebaseInfo()
        
    }
    
    func firebaseInfo() {
        let user = Auth.auth().currentUser
        if let user = user {
            let displayName = user.displayName
            displayNameLabel.text = "\(displayName!)'s Journey"
            let photoURL = user.photoURL!
            print(photoURL)
            
            // Prepare image view for reuse.
            profilePicture.image = nil
            
            // Previous requests for the image view get cancelled.
            Manager.shared.loadImage(with: photoURL, into: profilePicture)
            
            
            
//            Nuke.Manager.shared.loadImage(with: "\((Auth.auth().currentUser?.uid)!)/profilePicture.jpg", into: profilePicture)
//            let data = try? Data(contentsOf: photoURL)
//
//            let imageData = try? Data(contentsOf: photoURL)
//
//            let image = UIImage(data: imageData!)
//
//
//            profilePicture.image = image
//
//            // Create a storage reference from the URL
//            let storageRef = Storage.storage().reference(withPath: "\((Auth.auth().currentUser?.uid)!)/profilePicture.jpg")
//            //            let imageRef = storageRef.child("\((Auth.auth().currentUser?.uid)!)/profilePicture.jpg")
//
//            //             Download the data, assuming a max size of 1MB (you can change this as necessary)
//            storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
//                // Create a UIImage, add it to the array
//                let pic = UIImage(data: data!)
//                self.profilePicture.image = pic
//            }
        }
    }
    
    // MARK: - Navigation bar
    
    //This is to hide the navigation controller on the journal view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //Verify if user is connected
        print("User Login Status: \(isUserLoggedIn())")
        //If connected, go directly to the journal view
        if isUserLoggedIn() == false {
            performSegue(withIdentifier: "JournalToIntroduction", sender: self)
        }
        
        
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //This is to show the navigation controller on other views
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
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
    
    func isUserLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
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
