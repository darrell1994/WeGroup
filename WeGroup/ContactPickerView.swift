//
//  ContactPickerView.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/1/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class ContactPickerView: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ContactPickerView: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! ContactCell
        cell.user = Data.contacts[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = Data.contacts[indexPath.row]
        let conversation_obj = PFObject(className: "Conversation")
        conversation_obj["from"] = PFUser.currentUser()
        conversation_obj["to"] = user
        conversation_obj.saveInBackgroundWithBlock { (success, error) -> Void in
            if success {
                let newConversation = Conversation(id: conversation_obj.objectId!, toUsers: [user])
                Data.conversations.append(newConversation)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print("Failed to add conversation")
            }
        }
    }
}
