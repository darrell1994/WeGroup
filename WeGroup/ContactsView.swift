//
//  ContactsView.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/26/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class ContactsView: UIViewController, ContactDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredContacts: [Contact]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        Data.contactDelegate = self
        Contact.contactDelegate = self
        
        filteredContacts = Data.contacts
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Data.checkNewContacts()
    }
    
    func newContactFetched() {
        filteredContacts = Data.contacts
        tableView.reloadData()
    }
    
    @IBAction func onAddFriend(sender: AnyObject) {
        let alert = UIAlertController(title: "Add Friend", message: "Enter username", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        
        alert.addAction(UIAlertAction(title: "Add Friend", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            if let username = textField.text {
                // check empty
                if username.isEmpty {
                    let emptyAlert = UIAlertController(title: "Please enter a username", message: nil, preferredStyle: .Alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                        self.onAddFriend("")
                    }))
                    self.presentViewController(emptyAlert, animated: true, completion: nil)
                }
                
                // check whether user exists
                let query = PFQuery(className: "_User")
                query.whereKey("username", equalTo: username)
                query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
                    if let friend = result?.first as? PFUser {
                        // check whether it is the current user
                        if friend.username == PFUser.currentUser()?.username {
                            self.popupMessage("Cannot add yourself")
                            return
                        }
                        // check if they are already freinds
                        for contact in Data.contacts {
                            if contact.username == friend.username {
                                self.popupMessage("You are already friends with \(friend.username!)")
                                return
                            }
                        }
                        // create relationship
                        let relationship1 = PFObject(className: "Friendship")
                        relationship1["user"] = PFUser.currentUser()!
                        relationship1["friend"] = friend
                        let relationship2 = PFObject(className: "Friendship")
                        relationship2["user"] = friend
                        relationship2["friend"] = PFUser.currentUser()!
                        relationship1.saveInBackground()
                        relationship2.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                                self.popupMessage("friend added")
                                let contact = Contact.getContactWithPFUser(friend)
                                Data.contacts.append(contact)
                                self.filteredContacts?.append(contact)
                                self.tableView.reloadData()
                            } else {
                                self.popupMessage("Failed to add friend")
                            }
                        })
                    } else {
                        self.popupMessage("Did not find any matching")
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func popupMessage(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToProfileView" {
            let vc = segue.destinationViewController as! ProfileView
            let indexPath = sender as! NSIndexPath
            vc.contact = filteredContacts[indexPath.row]
        }
    }
}

extension ContactsView: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredContacts = filteredContacts {
            return filteredContacts.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! ContactCell
        cell.contact = filteredContacts?[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        performSegueWithIdentifier("ToProfileView", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // deleting contact
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if let currentUser = PFUser.currentUser() {
            let friend = PFUser(outDataWithObjectId: Data.contacts[indexPath.row].contactID)
            let query1 = PFQuery(className: "Friendship")
            query1.whereKey("user", equalTo: currentUser)
            query1.whereKey("friend", equalTo: friend)
            let query2 = PFQuery(className: "Friendship")
            query2.whereKey("user", equalTo: friend)
            query2.whereKey("friend", equalTo: currentUser)
            
            _managedObjectContext.deleteObject(Data.contacts[indexPath.row])
            Data.contacts.removeAtIndex(indexPath.row)
            self.filteredContacts = Data.contacts
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            
            query1.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if let results = results {
                    for result in results {
                        result.deleteInBackground()
                    }
                }
            }
            query2.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                if let results = results {
                    for result in results {
                        result.deleteInBackground()
                    }
                }
            })
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            if searchText == "" {
                filteredContacts = Data.contacts
            } else {
                filteredContacts = Data.contacts.filter({ (user) -> Bool in
                    let username = user.username
                    return username.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil
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
        filteredContacts = Data.contacts
        tableView.reloadData()
    }
}