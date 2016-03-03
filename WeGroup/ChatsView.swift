//
//  ChatsView.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/4/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class ChatsView: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadContacts()
        
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "onTimer", userInfo: nil, repeats: true)
    }

    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onTimer() { // checks for new conversations
        loadConversations()
    }
    
    private func loadContacts() {
        let query = PFQuery(className: "Friendship")
        query.includeKey("friend")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let results = results {
                for result in results {
                    let user = result["friend"] as! PFUser
                    Data.contacts.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // loading conversations from the server
    // only receive conversations started by other users
    // conversations started by the current user is stored locally
    private func loadConversations() {
        let query = PFQuery(className: "Conversation")
        query.includeKey("from")
        query.whereKey("to", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let results = results {
                for result in results {
                    let conversation = Conversation(id: result.objectId!, toUsers: [result["from"] as! PFUser])
                    result.deleteInBackground()
                    Data.conversations.append(conversation)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func onAddConversation(sender: AnyObject) {
        self.performSegueWithIdentifier("ToContactPicker", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToChat" {
            let cell = sender as! ChatCell
            let indexPath = tableView.indexPathForCell(cell)
            let vc = segue.destinationViewController as! MessageView
            vc.conversation = Data.conversations[indexPath!.row]
        }
    }
}

extension ChatsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell") as! ChatCell
        cell.conversation = Data.conversations[indexPath.row]
        return cell
    }
}
