//
//  ViewController.swift
//  WeGroup
//
//  Created by Darrell Shi on 1/21/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit

class LoginView: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTwitterLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithComplition{ (user, error) -> () in
            if user != nil {
                self.performSegueWithIdentifier("ToTabBarController", sender: nil)
            } else {
                print(error)
            }
        }
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
