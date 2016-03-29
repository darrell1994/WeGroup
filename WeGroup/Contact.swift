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
    static var contactDelegate: ContactDelegate?
    static var currentContact: Contact?

    init(contactID: String, username: String, profileImageData: NSData?) {
        super.init(entity: contactEntity, insertIntoManagedObjectContext: _managedObjectContext)
        self.contactID = contactID
        self.username = username
        self.profileImageData = profileImageData
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    static func getCurrentUserContact()->Contact? {
        if let currentUser = PFUser.currentUser() {
            if currentContact == nil {
                let profileImageData = currentUser["profile_image"] as? NSData
                currentContact = Contact(contactID: currentUser.objectId!, username: currentUser.username!, profileImageData: profileImageData)
                if let region = currentUser["region"] as? String {
                    currentContact!.region = region
                }
                if let shortBio = currentUser["shortBio"] as? String {
                    currentContact!.shortBio = shortBio
                }
            }
            return currentContact
        } else {
            return nil
        }
    }
    
    static func setCurrentUserContactToNil() {
        currentContact = nil
    }
    
    static func getContactWithPFUser(user: PFUser)->Contact {
        let userID = user.objectId
        for contact in Data.contacts {
            if contact.contactID == userID {
                return contact
            }
        }
        let profileImageData = user["profile_image"] as? NSData
        
        let contact = Contact(contactID: user.objectId!, username: user.username!, profileImageData: profileImageData)
        
        if let region = user["region"] as? String {
            contact.region = region
        }
        if let shortBio = user["shortBio"] as? String {
            contact.shortBio = shortBio
        }
    
        return contact
    }
    
    static func getContactWithPFUserAutoAddRelationship(user: PFUser)->Contact {
        let userID = user.objectId
        for contact in Data.contacts {
            if contact.contactID == userID {
                return contact
            }
        }
        let contact = Contact(contactID: user.objectId!, username: user.username!, profileImageData: user["profile_image"] as? NSData)
        if let region = user["region"] as? String {
            contact.region = region
        }
        if let shortBio = user["shortBio"] as? String {
            contact.shortBio = shortBio
        }
        
        Data.contacts.append(contact)
        contactDelegate?.newContactFetched()
        
        let relationship1 = PFObject(className: "Friendship")
        relationship1["user"] = PFUser.currentUser()!
        relationship1["friend"] = user
        let relationship2 = PFObject(className: "Friendship")
        relationship2["user"] = user
        relationship2["friend"] = PFUser.currentUser()!
        relationship1.saveInBackground()
        relationship2.saveInBackground()
        
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
