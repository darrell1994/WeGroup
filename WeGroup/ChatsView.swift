//
//  ChatsView.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/4/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

var timer = NSTimer()
let didReceiveNewMessage = "didReceiveNewMessage"

class ChatsView: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
                
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "onTimer", userInfo: nil, repeats: true)
        
        checkNewContacts()

        onTimer()
    }

    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onTimer() { // checks for new conversations
        checkNewConversations()
        checkNewMessages()
    }
    
    private func checkNewContacts() {
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "Friendship")
            query.includeKey("friend")
            query.whereKey("user", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if let results = results {
                    Data.contacts.removeAll()
                    for result in results {
                        let user = result["friend"] as! PFUser
                        Data.contacts.append(user)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // loading conversations from the server
    // only receive conversations started by other users
    // conversations started by the current user is stored locally
    private func checkNewConversations() {
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "Conversation")
            query.includeKey("from")
            query.whereKey("to", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if let results = results {
                    for result in results {
                        if self.getConversationWithID(result.objectId!) == nil { // conversaiton does not exsit already
                            let conversation = Conversation(id: result.objectId!, toUsers: [result["from"] as! PFUser])
                            Data.conversations.append(conversation)
                        }
                        result.deleteInBackground()
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func checkNewMessages() {
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "Message")
            query.includeKey("from")
            query.whereKey("to", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock { (messages, error) -> Void in
                if let message_objs = messages {
                    for obj in message_objs {
                        if let conversation = self.getConversationWithID(obj["conversationID"] as! String) {
                            if conversation.messages == nil {
                                conversation.messages = [Message]()
                            }
                            conversation.messages?.append(Message.getMessagefromPFObject(obj))
                            conversation.updatedAt = NSDate()
                        } else {
                            let conversation = Conversation(id: obj["conversationID"] as! String, toUsers: [obj["from"] as! PFUser])
                            conversation.messages = [Message]()
                            Data.conversations.append(conversation)
                            conversation.messages?.append(Message.getMessagefromPFObject(obj))
                            conversation.updatedAt = NSDate()
                        }
                        obj.deleteInBackground()
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: didReceiveNewMessage, object: nil))
                        self.tableView.reloadData()
                    }}}
        }
    }
    
    private func getConversationWithID(id: String)->Conversation? {
        for conversation in Data.conversations {
            if conversation.id == id {
                return conversation
            }
        }
        return nil
    }
    
    @IBAction func onAddConversation(sender: AnyObject) {
        self.performSegueWithIdentifier("ToContactPicker", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToChat" {
            let cell = sender as! ConversationCell
            let indexPath = tableView.indexPathForCell(cell)
            let vc = segue.destinationViewController as! MessageView
            vc.conversation = Data.conversations[indexPath!.row]
        }
    }
}

extension ChatsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell") as! ConversationCell
        cell.conversation = Data.conversations[indexPath.row]
        return cell
    }
}
