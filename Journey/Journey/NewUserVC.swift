//
//  NewUserVC.swift
//  Journey
//
//  Created by Samuel Beaulieu on 2018-05-28.
//  Copyright © 2018 Samuel Beaulieu. All rights reserved.
//

import UIKit
import Photos

class NewUserVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imagePicked: UIImageView!
    
    
    let galleryPicker = UIImagePickerController()
    // create a method to fetch your photo asset and return an UIImage on completion
    func fetchImage(asset: PHAsset, completion: @escaping  (UIImage) -> ()) {
        let options = PHImageRequestOptions()
        options.version = .original
        PHImageManager.default().requestImageData(for: asset, options: options) {
            data, uti, orientation, info in
            guard let data = data, let image = UIImage(data: data) else { return }
            self.imagePicked.contentMode = .scaleAspectFill
            self.imagePicked.image = image
            print("image size:", image.size)
            completion(image)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // lets add a selector to when the user taps the image
//        let tap = UITapGestureRecognizer(target: self, action: #selector(openPicker))
//        imagePicked.isUserInteractionEnabled = true
//        imagePicked.addGestureRecognizer(tap)
    }
    // opens the image picker for photo library
    @objc func openPicker() {
        galleryPicker.sourceType = .photoLibrary
        galleryPicker.delegate = self
        present(galleryPicker, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check if there is an url saved in the user defaults
        // and fetch its first object (PHAsset)
        if let url = UserDefaults.standard.url(forKey: "assetURL"),
            let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: PHFetchOptions()).firstObject {
            fetchImage(asset: asset) {
                        self.imagePicked.image = $0
                    }
                }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        print("canceled")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let url = info[UIImagePickerControllerReferenceURL] as? URL,
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UserDefaults.standard.set(url, forKey: "assetURL")
            print("url saved")
            self.imagePicked.image = image
        }
        dismiss(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func choosePhoto(_ sender: Any) {
        let alertController = UIAlertController(title: "Action Sheet", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Send now", style: .default, handler: { (action) -> Void in
            print("Send button tapped")
            self.openPicker()
        })
        
        let  deleteButton = UIAlertAction(title: "Delete forever", style: .destructive, handler: { (action) -> Void in
            print("Delete button tapped")
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(sendButton)
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
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
