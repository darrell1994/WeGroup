//
//  ChatsView.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/4/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

var timer = NSTimer()

class ConversationsView: UIViewController, ConversationDelegate {
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredConversations: [Conversation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        Data.conversationDelegate = self
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(ConversationsView.onTimer), userInfo: nil, repeats: true)
        
        Data.loadContactsFromLocalStorage(nil)
        Data.loadConversationsFromLocalStorage { () -> Void in
            self.filteredConversations = Data.conversations
            self.tableView.reloadData()
        }
        Data.checkNewContacts()
        onTimer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        filteredConversations = Data.conversations
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onTimer() {
        if Data.isConnectedToNetwork() {
            Data.checkNewMessages()
        }
    }
    
    func newConversationCreated(indexPath: NSIndexPath) {
        filteredConversations = Data.conversations
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func conversationUpdated() {
        filteredConversations = Data.conversations
        tableView.reloadData()
    }
    
    @IBAction func onAddConversation(sender: AnyObject) {
        self.performSegueWithIdentifier("ToContactPicker", sender: nil)
    }
    
    /*
    private func moveConversationToTop(index: Int) {
        if index < Data.conversations.count {
            let conversation = Data.conversations[index]
            Data.conversations.removeAtIndex(index)
            Data.conversations.insert(conversation, atIndex: 0)
            filteredConversations = Data.conversations
            tableView.reloadData()
        }
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToChat" {
            searchBarCancelButtonClicked(searchBar)
            let indexPath = sender as! NSIndexPath
            let vc = segue.destinationViewController as! MessageView
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! ConversationCell
            vc.navigationItem.title = cell.usernameLabel.text
            vc.conversation = filteredConversations![indexPath.row]
        }
    }
}

extension ConversationsView: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let conversations = filteredConversations {
            return conversations.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell") as! ConversationCell
        cell.conversation = filteredConversations![indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ToChat", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // deleting conversation
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        _managedObjectContext.deleteObject(Data.conversations[indexPath.row])
        Data.conversations.removeAtIndex(indexPath.row)
        filteredConversations?.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            if searchText == "" {
                filteredConversations = Data.conversations
            } else {
                filteredConversations = Data.conversations.filter({ (conversation) -> Bool in
                    for user in conversation.toUsers {
                        let contact = user as! Contact
                        let username = contact.username
                        if username.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) == nil {
                            continue
                        } else {
                            return true
                        }
                    }
                    return false
                })
            }
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredConversations = Data.conversations
        tableView.reloadData()
    }
}
