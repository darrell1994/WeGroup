//
//  Message.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import Parse

class Message {
    var from: PFUser?
    var to: PFUser?
    var text: String?
    
    init(from: PFUser?, to: PFUser?, text: String?) {
        self.from = from
        self.to = to
        self.text = text
    }
    
    static func getMessagefromPFObject(object: PFObject) -> Message {
        let from = object["from"] as? PFUser
        let to = object["to"] as? PFUser
        let text = object["text"] as? String
        let message = Message(from: from, to: to, text: text)
        return message
    }
}