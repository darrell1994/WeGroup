//
//  ViewController.swift
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
    
    @IBAction func onLogin(sender: AnyObject) {
        processIndicator.startAnimating()
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) { (user, error) -> Void in
            self.processIndicator.stopAnimating()
            if user != nil {
                self.performSegueWithIdentifier("ToMainPage", sender: nil)
            } else {
                print(error.debugDescription)
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
        self.presentViewController(alert, animated: true) { () -> Void in
            let recognizer = UITapGestureRecognizer(target: self, action: "onTapBackgroundWithSegue")
            alert.view.superview?.addGestureRecognizer(recognizer)
        }
    }
    
    func onTapBackground() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
