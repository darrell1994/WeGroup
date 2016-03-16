//
//  Contacts.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import CoreData
import Parse

struct Data {
    static var contacts = [Contact]()
    static var conversations = [Conversation]()
    
    static func loadContactsFromLocalStorage(completion: (()->Void)?) {
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        do {
            if let results = try _managedObjectContext.executeFetchRequest(fetchRequest) as? [Contact] {
                for contact in results {
                    if contact.contactID == PFUser.currentUser()!.objectId {
                        continue
                    }
                    print("loading \(contact.username) from local storage")
                    contacts.append(contact)
                }
            }
        } catch {
            fatalError("Error fetching data!")
        }
    }
    
    static func loadConversationsFromLocalStorage(completion: (()->Void)?) {
        let fetchRequest = NSFetchRequest(entityName: "Conversation")
        do {
            if let results = try _managedObjectContext.executeFetchRequest(fetchRequest) as? [Conversation] {
                for conversation in results {
                    conversations.append(conversation)
                }
                completion?()
            }
        } catch {
            fatalError("Error fetching data!")
        }
    }
    
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
                            let contact = Contact.getContactWithPFUser(user)
                            print("adding \(contact.username) from server")
                            Data.contacts.append(contact)
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
                            var users = [Contact]()
                            for chatter in chatters {
                                users.append(Contact.getContactWithPFUser(chatter))
                            }
                            let message = Message.getMessagefromPFObject(obj)
                            if let conversation = getConversationWithContacts(Contact.getContactsWithPFUsers(chatters)) {
                                conversation.appendMessage(message)
                            } else {
                                let conversation = Conversation(toUsers: users, isGroupChat: true)
                                conversation.appendMessage(message)
                                Data.conversations.append(conversation)
                            }
                        } else {
                            // if the conversation already exists
                            let from = Contact.getContactWithPFUser(obj["from"] as! PFUser)
                            let message = Message.getMessagefromPFObject(obj)
                            if let conversation = self.getConversationWithContact(from) {
                                conversation.appendMessage(message)
                            } else {
                                let conversation = Conversation(toUsers: [from], isGroupChat: false)
                                conversation.appendMessage(message)
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
    
    static func getConversationWithContact(contact: Contact)->Conversation? {
        for conversation in conversations {
            let toUsers = conversation.toUsers.allObjects as! [Contact]
            if toUsers.first?.username == contact.username {
                return conversation
            }
        }
        return nil
    }
    
    static func getConversationWithContacts(contacts: [Contact])->Conversation? {
        let users1 = contacts.sort { (user1, user2) -> Bool in
            if user1.contactID < user2.contactID {
                return true
            }
            return false
        }
        let contactsCount = contacts.count
        for conversation in conversations {
            if conversation.toUsers.count == contactsCount {
                let users2 = conversation.toUsers.sort({ (user1, user2) -> Bool in
                    if user1.contactID < user2.contactID {
                        return true
                    }
                    return false
                })
                
                for index in 0...contactsCount-1 {
                    if users1[index].contactID != users2[index].contactID {
                        break
                    }
                    if index == contactsCount-1 {
                        return conversation
                    }
                }
            }
        }
        return nil
    }
    
    static func clearAllContacts() {
        for contact in Data.contacts {
            _managedObjectContext.deleteObject(contact)
        }
        Data.contacts.removeAll()
    }
    
    static func clearAllConversations() {
        for conversation in Data.conversations{
            _managedObjectContext.deleteObject(conversation)
        }
        Data.conversations.removeAll()
    }
}