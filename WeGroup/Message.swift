//
//  Message.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import Parse

struct Message {
    var from: PFUser?
    var text: String?
    
    init(from: PFUser, text: String?) {
        self.from = from
        self.text = text
    }
    
    static func getMessagefromPFObject(object: PFObject) -> Message {
        let from = object["from"] as! PFUser
        let text = object["text"] as? String
        let message = Message(from: from, text: text)
        return message
    }
}