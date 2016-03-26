//
//  MessageView.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class MessageView: UIViewController, MessageDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputBox: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    var inputBoxEditing = false
    var conversation: Conversation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 63
        inputBox.delegate = self
        Data.messageDelegate = self
        
        inputBox.sizeToFit()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageView.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageView.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setTabBarVisible(false, animated: true)
        tableViewScrollToBottom(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        setTabBarVisible(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onSend(sender: AnyObject) {
        let messageText = inputBox.text
        conversation.appendMessage(Message(text: messageText, from: Contact.getContactWithPFUser(PFUser.currentUser()!)))
        conversation.updatedAt = NSDate()
        let index = conversation.messages.count-1
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
//        tableView.reloadData()
        tableViewScrollToBottom(true)
        inputBox.text = ""
        sendButton.enabled = false
        if conversation.toUsers.count == 1 { // direct chat
            let message_obj = PFObject(className: "Message")
            message_obj["from"] = PFUser.currentUser()
            let user = conversation?.toUsers.allObjects[0] as! Contact
            message_obj["to"] = PFUser(outDataWithObjectId: user.contactID)
            message_obj["text"] = messageText
            message_obj["isGroupMessage"] = false
            message_obj["chatters"] = [PFUser]()
            message_obj.saveInBackgroundWithBlock({ (success, error) -> Void in
                if !success {
                    print("Failed to send message")
                }
            })
        } else { // group chat
            for user in conversation.toUsers {
                let message_obj = PFObject(className: "Message")
                message_obj["from"] = PFUser.currentUser()
                message_obj["to"] = PFUser(outDataWithObjectId: (user as! Contact).contactID)
                message_obj["text"] = messageText
                message_obj["isGroupMessage"] = true
                var chatters = [PFUser]()
                chatters.append(PFUser.currentUser()!)
                for contact in conversation.toUsers {
                    let user = PFUser(outDataWithObjectId: (contact as! Contact).contactID)
                    chatters.append(user)
                }
                message_obj["chatters"] = chatters
                message_obj.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if !success {
                        // TODO warn user
                        print("Failed to send message")
                    }
                })
            }
        }
    }
    
    func newMessageReceived(indexPath: NSIndexPath) {
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        tableViewScrollToBottom(true)
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
        cell.message = messages.objectAtIndex(indexPath.row) as! Message
        
        return cell
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
            self.tableViewScrollToBottom(true)
        }
    }
    
    func keyboardWillHide() {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
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
        if (tabBarIsVisible() == visible) { return }
        
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
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
    
    func tableViewScrollToBottom(animated: Bool) {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
        })
    }
}