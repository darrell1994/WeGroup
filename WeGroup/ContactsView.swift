//
//  ContactsView.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/26/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class ContactsView: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredContacts: [PFUser]?
    var deleting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        filteredContacts = Data.contacts
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        Data.checkNewContacts { () -> Void in
            self.filteredContacts = Data.contacts
            self.tableView.reloadData()
        }
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
                        relationship1.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                            } else {
                                self.popupMessage("Failed to add friend")
                            }
                        })
                        relationship2.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                                self.popupMessage("friend added")
                                Data.contacts.append(friend)
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
    
    @IBAction func onDelete(sender: AnyObject) {
        if deleting {
            navigationItem.leftBarButtonItem?.title = "Delete"
            deleting = false
        } else {
            navigationItem.leftBarButtonItem?.title = "Cancel"
            deleting = true
        }
    }
    
    private func popupMessage(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
        cell.user = filteredContacts?[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if deleting {
            if let currentUser = PFUser.currentUser() {
                let friend = Data.contacts[indexPath.row]
                let query1 = PFQuery(className: "Friendship")
                query1.whereKey("user", equalTo: currentUser)
                query1.whereKey("friend", equalTo: friend)
                let query2 = PFQuery(className: "Friendship")
                query2.whereKey("user", equalTo: friend)
                query2.whereKey("friend", equalTo: currentUser)
                query2.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                    if let results = results {
                        for result in results {
                            result.deleteInBackground()
                        }
                    }
                })
                query1.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                    if let results = results {
                        for result in results {
                            result.deleteInBackgroundWithBlock({ (success:Bool, error) -> Void in
                                if success {
                                    Data.contacts.removeAtIndex(indexPath.row)
                                    self.filteredContacts = Data.contacts
                                    self.tableView.reloadData()
                                }
                            })
                        }
                    }
                }
            }
        } else {
            // TODO add a user profile page
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            if searchText == "" {
                filteredContacts = Data.contacts
            } else {
                filteredContacts = Data.contacts.filter({ (user :PFUser) -> Bool in
                    let username = user.username
                    return username?.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil) != nil
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