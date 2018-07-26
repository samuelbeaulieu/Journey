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
import FBSDKLoginKit
import Kingfisher

class JourneyTVC: UITableViewController {
    
    // MARK: - References
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var statsBg: UIView!
    @IBOutlet weak var postCountLabel: UILabel!
    
    // MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var defaultDisplayName:String = "John Smith"
    var userInfo = NSDictionary()
    
    var storageRef : StorageReference!
    
    var refPost : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reference to the database for the post
        self.refPost = Database.database().reference().child("posts")
        
        //Style for the navigation bar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.appDelegate.darkMode == true {
            UIApplication.shared.statusBarStyle = .lightContent
            self.navigationController?.navigationBar.barStyle = .black
            statsBg.backgroundColor = UIColor.lightGray
            postCountLabel.textColor = UIColor.white
            view.backgroundColor = UIColor.darkGray
        } else {
            UIApplication.shared.statusBarStyle = .default
            self.navigationController?.navigationBar.barStyle = .default
            statsBg.backgroundColor = UIColor.groupTableViewBackground
            postCountLabel.textColor = UIColor.darkGray
            view.backgroundColor = UIColor.white
        }
        
        //Print user login status
        print("User Login Status: \(isUserLoggedIn())")
//        try! Auth.auth().signOut()
        //If not connected, go directly to the introduction view
        if isUserLoggedIn() == false {
            //Create the default user profile
            self.appDelegate.posts.removeAll()
            self.tableView.reloadData()
            self.displayNameLabel.text = defaultDisplayName
            self.profilePhoto.image = UIImage(named: "Profile")
            performSegue(withIdentifier: "JourneyToIntroduction", sender: self)
        }
        if isUserLoggedIn() == true {
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
            if Auth.auth().currentUser?.displayName == nil {
                //Create the default user profile
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = defaultDisplayName
                changeRequest?.commitChanges { (error) in
                    print(error?.localizedDescription)
                }
            } else {
                
                if let providerData = Auth.auth().currentUser?.providerData {
                    for userInfo in providerData {
                        switch userInfo.providerID {
                        case "facebook.com":
                            print("user is signed in with facebook")
                            getUserInfo()
                        default:
                            print("user is signed in with \(userInfo.providerID)")
                            //Firebase Storage Reference
                            self.storageRef = Storage.storage().reference().child("\((Auth.auth().currentUser?.uid)!)/profilePhoto.jpg")
                            downloadPhoto()
                        }
                    }
                }

                
                fetchData()
                if self.appDelegate.posts.count > 0 {
                    self.tableView.reloadData()
                    if self.appDelegate.darkMode == true {
                        self.tableView.backgroundColor = UIColor.darkGray
                        self.tableView.separatorColor = UIColor.lightGray
                    } else {
                        self.tableView.backgroundColor = UIColor.white
                        self.tableView.separatorColor = UIColor.lightGray
                    }
                    
                } else {
                    postCountLabel.text = "Add a post to see it below!"
                    
                    if self.appDelegate.darkMode == true {
                        self.tableView.backgroundColor = UIColor.lightGray
                        self.tableView.separatorColor = UIColor.lightGray
                    } else {
                        self.tableView.backgroundColor = UIColor.groupTableViewBackground
                        self.tableView.separatorColor = UIColor.groupTableViewBackground
                    }
                }
                
                let userDisplayName = Auth.auth().currentUser?.displayName
                displayNameLabel.text = userDisplayName!
                
                
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    //This is to hide the navigation controller on this view
    override func viewWillAppear(_ animated: Bool) {
        
        //This will hide the navigation bar on this view
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if self.appDelegate.darkMode == true {
            return .lightContent
        } else {
            return .default
        }
    }
    
    //This is to show the navigation controller on other views
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
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
    
    //MARK: - Photo
    func downloadPhoto() {
        // get the download URL
        storageRef.downloadURL { url, error in
            if let error = error {
                print("error downlaoding image :\(error.localizedDescription)")
//                self.profilePhoto.image = UIImage(named: "Profile")
            } else {
                    self.profilePhoto.kf.setImage(with: url)
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tableView.beginUpdates()
            print(self.appDelegate.posts)
            print(indexPath.row)
            self.refPost.child((Auth.auth().currentUser?.uid)!).child(self.appDelegate.posts[indexPath.row].id!).removeValue()
            print(self.appDelegate.posts)
            print(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            self.appDelegate.posts.remove(at: indexPath.row)
            if self.appDelegate.posts.count > 0 {
                self.tableView.reloadData()
            } else {
                postCountLabel.text = "Add a post to see it below!"
                self.tableView.backgroundColor = UIColor.lightGray
            }
            self.tableView.endUpdates()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.appDelegate.posts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 325
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        
        if self.appDelegate.darkMode == true {
            cell.backgroundColor = UIColor.darkGray
            cell.postText.textColor = UIColor.white
            cell.timeLabel.textColor = UIColor.white
            cell.locationLabel.textColor = UIColor.white
            cell.locationPhoto.tintColor = UIColor.white
            cell.timePhoto.tintColor = UIColor.white
            cell.locationPhoto.image = UIImage(named: "PinWhite")
            cell.timePhoto.image = UIImage(named: "ClockWhite")
        } else {
            cell.backgroundColor = UIColor.white
            cell.postText.textColor = UIColor.darkGray
            cell.timeLabel.textColor = UIColor.darkGray
            cell.locationLabel.textColor = UIColor.darkGray
            cell.locationPhoto.image = UIImage(named: "Pin")
            cell.timePhoto.image = UIImage(named: "Clock")
        }
        
        cell.postPhoto.layer.cornerRadius = 5
        profilePhoto.layer.masksToBounds = false
        profilePhoto.clipsToBounds = true
        
        if self.appDelegate.posts.count > 0 {
            let post = self.appDelegate.posts[indexPath.item]
            if post.image != nil {
                cell.postPhoto.image = post.image
            } else {
                let storageRef = Storage.storage().reference().child((Auth.auth().currentUser?.uid)!).child("posts").child((post.id)!)
                // get the download URL
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("error downlaoding image :\(error.localizedDescription)")
                    } else {
                        cell.postPhoto.kf.setImage(with: url)
                        self.appDelegate.posts.remove(at: indexPath.item)
                        self.appDelegate.posts.insert(post, at: indexPath.item)
                    }
                }
            }
            cell.locationLabel.text = post.location
            cell.timeLabel.text = post.date
            cell.postText.text = post.text
        }
        return cell
    }
    
    func fetchData(){
        self.refPost.child((Auth.auth().currentUser?.uid)!).observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.appDelegate.posts.removeAll()
                print("snapshot.childrenCount : \(snapshot.childrenCount)")
                for posts in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let postObject = posts.value as? [String: AnyObject]
                    //print(artistObject)
                    let postId  = postObject?["id"]
                    //print(artistId)
                    let postText  = postObject?["text"]
                    let postLocation  = postObject?["location"]
                    let postDate  = postObject?["date"]
                    
                    //creating artist object with model and fetched values
                    let post = Post(id: (postId! as! String),
                                        text: (postText as! String?)!,
                                        location:(postLocation as! String?)!,
                                        date: (postDate as! String?)!,
                                        image: nil
                    )
                    self.appDelegate.posts.insert(post, at: 0)
                    self.tableView.reloadData()
                    self.postCountLabel.text = "\(self.appDelegate.posts.count) Posts"
                    
                    
                }
                
            }
        }
    }
    
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
