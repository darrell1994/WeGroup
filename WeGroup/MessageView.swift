//
//  MessageView.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

var messageTimer = NSTimer()

class MessageView: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var conversation: Conversation!
    @IBOutlet weak var inputBox: UITextView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    var inputBoxEditing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 63
        inputBox.delegate = self
        
        inputBox.sizeToFit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onReceiveNewMessage", name: didReceiveNewMessage, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setTabBarVisible(false, animated: true)
        if let messages = conversation?.messages {
            conversation.messages = messages
        } else {
            conversation.messages = [Message]()
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        setTabBarVisible(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onSend(sender: AnyObject) {
        let message_obj = PFObject(className: "Message")
        message_obj["from"] = PFUser.currentUser()
        message_obj["to"] = conversation?.toUsers.first
        message_obj["text"] = inputBox.text
        message_obj.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                self.conversation.messages.append(Message(from: PFUser.currentUser(), to: self.conversation?.toUsers.first, text: self.inputBox.text))
                self.conversation.updatedAt = NSDate()
                self.tableView.reloadData()
                self.inputBox.text = ""
            } else {
                // TODO warn user
                print("Failed to send message")
            }
        })
    }
    
    func onReceiveNewMessage() {
        tableView.reloadData()
    }
}

extension MessageView: UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate {
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            self.setTabBarVisible(true, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        let messages = conversation.messages
            cell.message = messages[indexPath.row]
        
//        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if inputBoxEditing {
            inputBox.resignFirstResponder()
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        inputBoxEditing = true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        inputBoxEditing = false
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.bottomConstraint.constant = frame.height
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide() {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text == "" {
            if sendButton.enabled {
                sendButton.enabled = false
            }
        } else {
            if !sendButton.enabled {
                sendButton.enabled = true
            }
        }
        
        let frameHeight = textView.frame.size.height
        let contentHeight = textView.contentSize.height
        
        if frameHeight != contentHeight {
            textView.frame.size.height = contentHeight
            textViewHeightConstraint.constant = contentHeight
        }
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }
}