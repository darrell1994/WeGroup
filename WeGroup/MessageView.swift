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
    @IBOutlet weak var inputBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        inputBox.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onReceiveNewMessage", name: didReceiveNewMessage, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        if let messages = conversation?.messages {
            conversation.messages = messages
        } else {
            conversation.messages = [Message]()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onSend() {
        let message_obj = PFObject(className: "Message")
        message_obj["from"] = PFUser.currentUser()
        message_obj["to"] = conversation?.toUsers.first
        message_obj["text"] = inputBox.text
        message_obj["conversationID"] = conversation.id
        message_obj.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                self.conversation.messages?.append(Message(from: PFUser.currentUser(), to: self.conversation?.toUsers.first, text: self.inputBox.text))
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

extension MessageView: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = conversation.messages {
            return messages.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell")!
        if let messages = conversation.messages {
            cell.textLabel?.text = messages[indexPath.row].from!.username! + ": " + messages[indexPath.row].text!
        }
        
        return cell
    }
    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        let gesture = UITapGestureRecognizer(target: self, action: "onDismissKeyboard")
//        self.view.addGestureRecognizer(gesture)
//    }
//    
//    func onDismissKeyboard() {
//        view.endEditing(true)
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        onSend()
        textField.resignFirstResponder()
        return true
    }
}