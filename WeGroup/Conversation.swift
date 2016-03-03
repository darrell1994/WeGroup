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
    var messages: [Message]?
    var toUsers: [PFUser]
    var updatedAt: NSDate?
    
    init(id: String, toUsers: [PFUser]) {
        self.id = id
        self.toUsers = toUsers
    }
}