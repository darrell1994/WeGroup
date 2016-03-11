//
//  Contacts.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import Parse

struct Data {
    static var contacts = [PFUser]()
    static var conversations = [Conversation]()
    
    static func checkNewContacts(received: (()->Void)?) {
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "Friendship")
            query.includeKey("friend")
            query.whereKey("user", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if let results = results {
                    if results.count > contacts.count {
                        // TODO inform user that new friends have been added
                        print("New friends added!")
                        
                        Data.contacts.removeAll()
                        for result in results {
                            let user = result["friend"] as! PFUser
                            Data.contacts.append(user)
                        }
                        received?()
                    }
                }
            }
        }
    }
    
    static func checkNewMessages(received: (()->Void)?) {
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "Message")
            query.includeKey("from")
            query.whereKey("to", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if let objects = objects {
                    if objects.count == 0 {
                        return
                    }
                    for obj in objects {
                        // if the conversation already exists
                        let from = obj["from"] as! PFUser
                        let message = Message.getMessagefromPFObject(obj)
                        if let conversation = self.getConversationWithUser(from) {
                            conversation.messages.append(message)
                        } else {
                            let conversation = Conversation(toUsers: [from])
                            conversation.messages.append(message)
                            Data.conversations.append(conversation)
                        }
                        obj.deleteInBackground()
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(didReceiveNewMessage, object: nil)
                    received?()
                }
            }}
    }
    
    /*
    static func checkNewConversations(received: (()->Void)?) {
        if let currentUser = PFUser.currentUser() {
            let query = PFQuery(className: "Conversation")
            query.includeKey("from")
            query.whereKey("to", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if let results = results {
                    for result in results {
                        if let conversation = self.getConversationWithUsers([result["from"] as! PFUser]) {
                            // TODO fix the duplicate conversation problem
                            // A starts several new conversations with B
                            // B still has the conversation in the list
                        }
                        
//                        }
//                        if self.getConversationWithID(result.objectId!) == nil { // conversaiton does not exsit already
                            let conversation = Conversation(id: result.objectId!, toUsers: [result["from"] as! PFUser])
                            Data.conversations.append(conversation)
                            // Sort conversations by time
                        
                        result.deleteInBackground()
                    }
                    received?()
                }
            }
        }
    }
    */
    
    static func getConversationWithUser(user: PFUser)->Conversation? {
        for conversation in conversations {
            if conversation.toUsers.first?.username == user.username {
                return conversation
            }
        }
        return nil
    }
}