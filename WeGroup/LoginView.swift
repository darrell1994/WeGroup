//
//  LoginView.swift
//  WeGroup
//
//  Created by Darrell Shi on 1/21/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse
import BALoadingView

class LoginView: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var loadingIndicator: BALoadingView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        setupLoadingIndicator()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = BALoadingView.init(frame: CGRect(x: view.frame.width/2-20, y: 172, width: 40, height: 40))
        loadingIndicator.initialize()
        loadingIndicator.segmentColor = UIColor.whiteColor()
        loadingIndicator.lineCap = kCALineCapRound;
        self.view.addSubview(loadingIndicator)
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
        loadingIndicator.startAnimation(.FullCircle)
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) { (user, error) -> Void in
            self.loadingIndicator.stopAnimation()
            if user != nil {
                self.performSegueWithIdentifier("ToMainPage", sender: nil)
            } else {
                self.popupMessage("Failed to login", message: "Username and password don't match")
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
        let gesture = UITapGestureRecognizer(target: self, action: "onDismissKeyboard:")
        self.view.addGestureRecognizer(gesture)
    }
    
    func onDismissKeyboard(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
        self.view.removeGestureRecognizer(gesture)
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
