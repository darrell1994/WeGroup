//
//  SettingsView.swift
//  WeGroup
//
//  Created by Hanqi Du on 2/12/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse
import CoreData

class SettingsView: UITableViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoutProcessIndicator: UIActivityIndicatorView!
    @IBOutlet weak var regionTextField: UITextField!
    @IBOutlet weak var shortBioTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        regionTextField.delegate = self
        shortBioTextField.delegate = self
//        self.navigationController?.navigationBarHidden = false
//        self.tableView.tableFooterView = UIView()
        
        nameLabel.text = PFUser.currentUser()?.username
        profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 28
        if let profileData = PFUser.currentUser()?["profile_image"] as? NSData {
            let image = UIImage(data: profileData)
            profileImageView.image = image
        }
        if let region = PFUser.currentUser()?["region"] as? String {
            regionTextField.text = region
        }
        if let shortBio = PFUser.currentUser()?["shortBio"] as? String {
            shortBioTextField.text = shortBio
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsView.onChangeProfile))
        gestureRecognizer.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onChangeProfile() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action: UIAlertAction) -> Void in
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            vc.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(vc, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
        
    private func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func uploadProfile() {
        let profileImage = profileImageView.image!
        let user = PFUser.currentUser()
        if let imageData = UIImagePNGRepresentation(profileImage) {
            user!["profile_image"] = imageData
            user?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.popupMessage("Profile uploaded!")
                } else {
                    self.popupMessage("Failed to upload profile image")
                    print(error.debugDescription)
                }
            })
        }
    }
    
    private func popupMessage(message: String?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true) { () -> Void in
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsView.onTapBackground))
            alert.view.superview?.addGestureRecognizer(recognizer)
        }
    }
    
    func onTapBackground() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logoutClicked(sender: AnyObject) {
        logoutProcessIndicator.startAnimating()
        timer.invalidate()
        
        PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
            if error != nil {
                print("Failed to logout")
            } else {
                Data.clearAllConversations()
                Data.clearAllContacts()
                self.logoutProcessIndicator.stopAnimating()
                self.dismissViewControllerAnimated(true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
            }
        })
    }
}

extension SettingsView: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let edited = info[UIImagePickerControllerEditedImage] as! UIImage
        profileImageView.image = resizeImage(edited, newSize: CGSize(width: 128, height: 128))
        picker.dismissViewControllerAnimated(true, completion: {()->Void in
            self.uploadProfile()
        })
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SettingsView.onUploadProfile))
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func onUploadProfile() {
        self.view.endEditing(true)
        if regionTextField.text?.characters.count > 100 {
            popupMessage("Region must be less than 100 characters")
            return
        }
        if shortBioTextField.text?.characters.count > 500 {
            popupMessage("Short bio must be less than 500 characters")
            return
        }
        if let user = PFUser.currentUser() {
            user.setValue(regionTextField.text, forKey: "region")
            user.setValue(shortBioTextField.text, forKey: "shortBio")
            user.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.navigationItem.rightBarButtonItem = nil
                    self.popupMessage("Profile updated successfully")
                } else {
                    self.popupMessage("Failed to upload profile")
                }
            })
        }
    }
}

