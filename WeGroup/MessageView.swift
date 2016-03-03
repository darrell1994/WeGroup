//
//  MessageView.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class MessageView: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var conversation: Conversation?
    var messages: [Message]?
    @IBOutlet weak var inputBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        inputBox.delegate = self
        
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "onTimer", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        if let messages = conversation?.messages {
            self.messages = messages
        } else {
            messages = [Message]()
            onTimer()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        conversation?.messages = messages
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onTimer() {
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "Message")
            query.includeKey("from")
            query.whereKey("to", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock { (messages, error) -> Void in
                if let message_objs = messages {
                    for obj in message_objs {
                        self.messages?.append(Message.getMessagefromPFObject(obj))
                        obj.deleteInBackground()
                        self.tableView.reloadData()
                    }}}
        }
    }
    
    @IBAction func onSend(sender: AnyObject) {
        if inputBox.text!.isEmpty {
            // TODO warn user
            print("input empty")
        } else {
            let message_obj = PFObject(className: "Message")
            message_obj["from"] = PFUser.currentUser()
            message_obj["to"] = conversation?.toUsers.first
            message_obj["text"] = inputBox.text
            message_obj.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    self.messages?.append(Message(from: PFUser.currentUser(), to: self.conversation?.toUsers.first, text: self.inputBox.text))
                    self.tableView.reloadData()
                    self.inputBox.text = ""
                } else {
                    // TODO warn user
                    print("Failed to send message")
                }
            })
        }
    }
}

extension MessageView: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell")!
        cell.textLabel?.text = messages![indexPath.row].from!.username! + ": " + messages![indexPath.row].text!
        return cell
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        onSend("")
        textField.resignFirstResponder()
        return true
    }
}