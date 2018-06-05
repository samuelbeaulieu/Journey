//
//  LoginWithEmailVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-05-25.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import CoreData

class LoginWithEmailVC: UIViewController {
    //References
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var emailAddressInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    var emailVerification:Bool = false
    var passwordVerification:Bool = false
    
    var userCDData:[User] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        printExistingEmail()
        //Style for the continue button
        continueButton.layer.cornerRadius = 25
        continueButton.layer.borderWidth = 1
        continueButton.layer.borderColor = UIColor.lightGray.cgColor
        
        
        emailAddressInput.addTarget(self, action: #selector(textFieldDidChange), for:.editingChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @objc func textFieldDidChange(){
        if someEntityExists(email: self.emailAddressInput.text!) == false {
            emailAddressInput.backgroundColor = UIColor(red:0.00, green:1.00, blue:0.00, alpha:0.1)
            //performSegue(withIdentifier: "loginWithEmailToNewUser", sender: self)
        } else {
            emailAddressInput.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:0.1)
            
            //performSegue(withIdentifier: "loginWithEmailToJournal", sender: self)
        }
        print(emailAddressInput.text)
    }
    
    @IBAction func loginContinue(_ sender: Any) {
        if emailAddressInput.text != "" && passwordInput.text != "" {
            if someEntityExists(email: self.emailAddressInput.text!) == false {
                performSegue(withIdentifier: "loginWithEmailToNewUser", sender: self)
            } else {
                performSegue(withIdentifier: "loginWithEmailToJournal", sender: self)
            }
        }
    }
    
    func saveToCoreData() {
        let context = self.appDelegate.persistentContainer.viewContext
        
        let userCD = User(context: context)
        userCD.email = self.emailAddressInput.text!
        userCD.password = self.passwordInput.text!
        userCD.name = ""//To be completed on the next view
        userCD.image = nil//To be completed on the next view
        userCD.facebook = false
        userCD.location = false//Default Value
        userCD.time = true//Default Value
        userCD.isNew = true
        userCD.creationDate = Date()
        
        self.appDelegate.saveContext()
        print("User : \n\tCreation Date : \(userCD.creationDate)\n\tEmail : \(userCD.email)\n\tPassword : \(userCD.password)\n\tName : \(userCD.name)\n\tImage : \(userCD.image)\n\tFacebook : \(userCD.facebook)\n\tLocation : \(userCD.location)\n\tTime : \(userCD.time)\n\tisNew : \(userCD.isNew)")
    }
    
    func someEntityExists(email: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let predicate = NSPredicate(format: "email == %@", self.emailAddressInput.text!)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let context = self.appDelegate.persistentContainer.viewContext
            let count = try context.count(for: request)
            if(count == 0){
                // no matching object
                print("no present")
                return false
            }
            else{
                // at least one matching object exists
                print("one matching item found")
                return true
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return true
    }
    
    func printExistingEmail() {
        let context = self.appDelegate.persistentContainer.viewContext

        do {
            self.userCDData = try context.fetch(User.fetchRequest())
            for item in self.userCDData {
                print(item.email as! String)
            }
        } catch {
            print("Fetching Email Failed")
        }
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
