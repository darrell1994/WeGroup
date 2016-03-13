//
//  Conversation.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import Parse

// I added this line

class Conversation {
    var messages: [Message]
    var toUsers: [PFUser]
    var updatedAt: NSDate
    var isGroupChat: Bool
    var profileColor: UIColor?
    
    init(toUsers: [PFUser]) {
        self.toUsers = toUsers
        self.messages = [Message]()
        self.updatedAt = NSDate()
        if toUsers.count == 1 {
            self.isGroupChat = false
        } else {
            self.isGroupChat = true
            profileColor = UIColor(red: CGFloat(Float(arc4random_uniform(256))/255), green: CGFloat(Float(arc4random_uniform(256))/255), blue: CGFloat(Float(arc4random_uniform(256))/255), alpha: 0.5)
        }
    }
}