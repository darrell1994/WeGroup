//
//  SignupView.swift
//  WeGroup
//
//  Created by Darrell Shi on 1/23/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class SignupView: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConformationTextField: UITextField!
    
    @IBOutlet weak var processIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConformationTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onSignup(sender: AnyObject) {
        if checkInputValidity() {
            processIndicator.startAnimating()
            let user = PFUser()
            user.username = usernameTextField.text
            user.email = emailTextField.text
            user.password = passwordTextField.text
            user.signUpInBackgroundWithBlock { (success, error) -> Void in
                self.processIndicator.stopAnimating()
                if success {
                    self.popupMessage(nil, message: "Welcome to WeGroup!", segue: true)
                } else {
                    print(error.debugDescription)
                    self.popupMessage(nil, message: "Failed to sign up", segue: false)
                }
            }
        }
    }
    
    private func checkInputValidity()->Bool {
        if usernameTextField.text == "" {
            popupMessage("Error", message: "Please provide username", segue: false)
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
        if passwordTextField.text != passwordConformationTextField.text {
            popupMessage("Error", message: "Password doesn't match password confirmation", segue: false)
            return false
        }
        return true
    }
    
    private func popupMessage(title: String?, message: String?, segue: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true) { () -> Void in
            var recognizer: UITapGestureRecognizer
            if segue {
                recognizer = UITapGestureRecognizer(target: self, action: "onTapBackgroundWithSegue")
            } else {
                recognizer = UITapGestureRecognizer(target: self, action: "onTapBackground")
            }
            alert.view.superview?.addGestureRecognizer(recognizer)
        }
    }
    
    func onTapBackground() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onTapBackgroundWithSegue() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("ToMainPage", sender: nil)
    }

}

extension SignupView: UITextFieldDelegate {
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
