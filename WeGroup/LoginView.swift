//
//  LoginView.swift
//  WeGroup
//
//  Created by Darrell Shi on 1/21/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class LoginView: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var processIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
    - checks if username is provided
    - checks if password is provided
    */
    private func checkInputValidity() -> Bool {
        if usernameTextField.text == "" {
            popupMessage("Error", message: "Please provide username")
            return false
        }
        if passwordTextField.text == "" {
            popupMessage("Error", message: "Please provide password")
            return false
        }
        return true
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        if !checkInputValidity() {
            return
        }
        processIndicator.startAnimating()
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) { (user, error) -> Void in
            self.processIndicator.stopAnimating()
            if user != nil {
                self.performSegueWithIdentifier("ToMainPage", sender: nil)
            } else {
                self.popupMessage("Failed to login", message: "Username and password don't match")
            }
        }
    }
    
    @IBAction func onTwitterLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithComplition{ (user, error) -> () in
            if user != nil {
                self.performSegueWithIdentifier("ToTabBarController", sender: nil)
            } else {
                self.popupMessage("Error", message: error?.debugDescription)
            }
        }
    }
    
    private func popupMessage(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        let gesture = UITapGestureRecognizer(target: self, action: "onDismissKeyboard")
        self.view.addGestureRecognizer(gesture)
    }
    
    func onDismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            onLogin("")
        }
        return true
    }
}
