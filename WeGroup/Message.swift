//
//  Message.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import Parse
import CoreData

class Message: NSManagedObject {
    init(text: String?, from: Contact) {
        super.init(entity: messageEntity, insertIntoManagedObjectContext: _managedObjectContext)
        self.text = text
        self.from = from
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    static func getMessagefromPFObject(object: PFObject) -> Message {
        let from = Contact.getContactWithPFUser(object["from"] as! PFUser)
        let text = object["text"] as? String
        let message = Message(text: text, from: from)
        return message
    }
}

extension Message {
    
    @NSManaged var text: String?
    @NSManaged var from: Contact
    
}