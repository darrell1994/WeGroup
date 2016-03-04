//
//  Conversation.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import Parse

class Conversation {
    var id: String
    var messages: [Message]
    var toUsers: [PFUser]
    var updatedAt: NSDate
    
    init(id: String, toUsers: [PFUser]) {
        self.id = id
        self.toUsers = toUsers
        self.messages = [Message]()
        self.updatedAt = NSDate()
    }
    
    static func checkNewConversations() {
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
                            // Sort conversations by time
                        }
                        result.deleteInBackground()
                    }
                }
            }
        }
    }
    
    private static func getConversationWithID(id: String)->Conversation? {
        for conversation in Data.conversations {
            if conversation.id == id {
                return conversation
            }
        }
        return nil
    }
}