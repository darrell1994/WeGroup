//
//  Contact.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/13/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import CoreData
import Parse

class Contact: NSManagedObject {
    init(contactID: String, username: String, profileImageData: NSData?) {
        super.init(entity: contactEntity, insertIntoManagedObjectContext: _managedObjectContext)
        self.contactID = contactID
        self.username = username
        self.profileImageData = profileImageData
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    static func getContactWithPFUser(user: PFUser)->Contact {
        let contact = Contact(contactID: user.objectId!, username: user.username!, profileImageData: user["profile_image"] as? NSData)
        if let region = user["region"] as? String {
            contact.region = region
        }
        if let shortBio = user["shortBio"] as? String {
            contact.shortBio = shortBio
        }
        return contact
    }
    
    static func getContactsWithPFUsers(users: [PFUser])-> [Contact] {
        var contacts = [Contact]()
        for user in users {
            contacts.append(getContactWithPFUser(user))
        }
        return contacts
    }
}

extension Contact {
    
    @NSManaged var contactID: String
    @NSManaged var username: String
    @NSManaged var profileImageData: NSData?
    @NSManaged var messages: NSSet?
    @NSManaged var conversations: NSSet?
    @NSManaged var region: String?
    @NSManaged var shortBio: String?
    
}
