//
//  JournalTVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-06-08.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class JournalTVC: UITableViewController {
    
    //References
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var dayCounterLabel: UILabel!
    @IBOutlet weak var postCounterLabel: UILabel!
    @IBOutlet weak var photoCounterLabel: UILabel!
    
    //Variables
    var newUser : Bool = true
    var storageRef : StorageReference!
    var userInfo = NSDictionary()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        //Style for the navigation bar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    //This is to hide the navigation controller on the journal view
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("You are in viewWillAppear")
        
        //Print user login status
        print("User Login Status: \(isUserLoggedIn())")
        
        //If not connected, go directly to the introduction view
        if isUserLoggedIn() == false {
            performSegue(withIdentifier: "JournalToIntroduction", sender: self)
        }
        
        if isUserLoggedIn() == true {
                //Firebase Storage Reference for profile picture
                self.storageRef = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid)!)/profilePhoto.jpg")
                
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                self.storageRef.getData(maxSize: 10 * 4096 * 4096) { data, error in
                    if error != nil {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        self.profilePhoto.image = image
                    }
                }
                Auth.auth().currentUser?.reload(completion: nil)
                let userDisplayName = Auth.auth().currentUser?.displayName!
                displayNameLabel.text = userDisplayName!
            
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //This is to show the navigation controller on other views
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
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
