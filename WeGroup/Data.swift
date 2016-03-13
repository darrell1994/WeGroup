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
            query.includeKey("chatters")
            query.whereKey("to", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if let objects = objects {
                    if objects.count == 0 {
                        return
                    }
                    for obj in objects {
                        // check direct or group chat
                        let isGroupMessage = obj["isGroupMessage"] as! Bool
                        if isGroupMessage {
                            // check if the conversation already exists
                            var chatters = obj["chatters"] as! [PFUser]
                            if let indexOfCurrentUser = indexOfCurrentUserInChatters(chatters) {
                                chatters.removeAtIndex(indexOfCurrentUser)
                            }
                            let message = Message.getMessagefromPFObject(obj)
                            if let conversation = getConversationWithUsers(chatters) {
                                conversation.messages.append(message)
                            } else {
                                let conversation = Conversation(toUsers: chatters)
                                conversation.messages.append(message)
                                Data.conversations.append(conversation)
                            }
                        } else {
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
                        }
                        obj.deleteInBackground()
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(didReceiveNewMessage, object: nil)
                    received?()
                }
            }}
    }
    
    private static func indexOfCurrentUserInChatters(chatters: [PFUser])->Int? {
        var index = 0
        for chatter in chatters {
            if chatter.username == PFUser.currentUser()?.username {
                return index
            }
            index++
        }
        return nil
    }
    
    static func getConversationWithUser(user: PFUser)->Conversation? {
        for conversation in conversations {
            if conversation.toUsers.first?.username == user.username {
                return conversation
            }
        }
        return nil
    }
    
    static func getConversationWithUsers(users: [PFUser])->Conversation? {
        let users1 = users.sort { (user1, user2) -> Bool in
            if user1.objectId < user2.objectId {
                return true
            }
            return false
        }
        let usersCount = users.count
        for conversation in conversations {
            if conversation.toUsers.count == usersCount {
                let users2 = conversation.toUsers.sort({ (user1, user2) -> Bool in
                    if user1.objectId < user2.objectId {
                        return true
                    }
                    return false
                })
                
                for index in 0...usersCount-1 {
                    if users1[index].objectId != users2[index].objectId {
                        break
                    }
                    if index == usersCount-1 {
                        return conversation
                    }
                }
            }
        }
        return nil
    }
}