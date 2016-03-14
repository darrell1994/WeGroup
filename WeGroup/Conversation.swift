//
//  Conversation.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import Parse
import CoreData

class Conversation: NSManagedObject {
    init(toUsers: [Contact], isGroupChat: Bool) {
        super.init(entity: conversationEntity, insertIntoManagedObjectContext: _managedObjectContext)
        self.toUsers = NSSet(array: toUsers)
        self.isGroupChat = isGroupChat
        self.updatedAt = NSDate()
        self.messages = NSOrderedSet(array: [Message]())
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    func appendMessage(message: Message) {
        let mutableItems = messages.mutableCopy() as! NSMutableOrderedSet
        mutableItems.addObject(message)
        messages = mutableItems.copy() as! NSOrderedSet
    }
    
//    var messages: [Message]
//    var toUsers: [PFUser]
//    var updatedAt: NSDate
//    var isGroupChat: Bool
//    var profileColor: UIColor?
//    
//    init(toUsers: [PFUser]) {
//        self.toUsers = toUsers
//        self.messages = [Message]()
//        self.updatedAt = NSDate()
//        if toUsers.count == 1 {
//            self.isGroupChat = false
//        } else {
//            self.isGroupChat = true
//            profileColor = UIColor(red: CGFloat(Float(arc4random_uniform(256))/255), green: CGFloat(Float(arc4random_uniform(256))/255), blue: CGFloat(Float(arc4random_uniform(256))/255), alpha: 0.5)
//        }
//    }
}

extension Conversation {
    
    @NSManaged var isGroupChat: Bool
    @NSManaged var updatedAt: NSDate
    @NSManaged var messages: NSOrderedSet
    @NSManaged var toUsers: NSSet
    
}