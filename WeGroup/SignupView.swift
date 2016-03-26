//
//  SignupView.swift
//  WeGroup
//
//  Created by Darrell Shi on 1/23/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse
import BALoadingView

class SignupView: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConformationTextField: UITextField!
    var loadingIndicator: BALoadingView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConformationTextField.delegate = self
        
        setupLoadingIndicator()
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = BALoadingView.init(frame: CGRect(x: view.frame.width/2-20, y: 172, width: 40, height: 40))
        loadingIndicator.initialize()
        loadingIndicator.segmentColor = UIColor.whiteColor()
        loadingIndicator.lineCap = kCALineCapRound;
        self.view.addSubview(loadingIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onSignup(sender: AnyObject) {
        if !checkInputValidity() {
           return
        }
        loadingIndicator.startAnimation(.FullCircle)
        let user = PFUser()
        user.username = usernameTextField.text
        user.email = emailTextField.text
        user.password = passwordTextField.text
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            self.loadingIndicator.stopAnimation()
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName(userDidLoginNotification, object: nil)
                let profile = Data.imageFromColor(Data.getRandomUIColor())
                if let user = PFUser.currentUser() {
                    if let imageData = UIImagePNGRepresentation(profile) {
                        user["profile_image"] = imageData
                        user.saveInBackground()
                    }
                }
                self.popupMessage("Success", message: "Welcome to WeGroup!", segue: true)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.popupMessage(nil, message: error!.localizedDescription, segue: false)
            }
        }
    }
    
    @IBAction func onBackToLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func checkInputValidity()->Bool {
        if usernameTextField.text == "" {
            popupMessage("Error", message: "Please provide username", segue: false)
            return false
        }
        if usernameTextField.text?.characters.count > 14 {
            popupMessage("Error", message: "Username must be 0-14 characters", segue: false)
            return false
        }
        if usernameTextField.text!.containsString(" ") {
            popupMessage("Error", message: "Username cannot contain white space", segue: false)
            return false
        }
        if emailTextField.text == "" {
            popupMessage("Error", message: "Please provide email address", segue: false)
            return false
        }
        if passwordTextField.text == "" || passwordConformationTextField.text == "" {
            popupMessage("Error", message: "Please provide both password and password confirmation", segue: false)
            return false
        }
        if passwordTextField.text?.characters.count < 6 {
            popupMessage("Error", message: "Password must be at least 6 characters", segue: false)
            return false
        }
        if passwordTextField.text != passwordConformationTextField.text {
            popupMessage("Error", message: "Password doesn't match password confirmation", segue: false)
            return false
        }
        return true
    }
    
    private func popupMessage(title: String?, message: String?, segue: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        if segue {
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier("ToMainPage", sender: nil)
                })
            )
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        }
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension SignupView: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SignupView.onDismissKeyboard))
        self.view.addGestureRecognizer(gesture)
    }
    
    func onDismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordConformationTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
