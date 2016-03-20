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
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredContacts: [Contact]?

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
    
    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onDoneSeletingContacts() {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            var selected = [Contact]()
            for indexPath in indexPaths {
                selected.append(filteredContacts![indexPath.row])
            }
            // check if the conversation already exits
            if let _ = Data.getConversationWithContacts(selected) {
                popupMessage(nil, message: "Conversation already exists")
            } else {
                var conversation: Conversation
                if selected.count == 1 { // direct chat
                    conversation = Conversation(toUsers: selected, isGroupChat: false)
                } else { // group chat
                    conversation = Conversation(toUsers: selected, isGroupChat: true)

                }
                Data.conversations.append(conversation)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
}

extension ContactPickerView: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contacts = filteredContacts {
            return contacts.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell") as! ContactCell
        cell.contact = filteredContacts?[indexPath.row]
        return cell
    }
    
    private func popupMessage(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            if indexPaths.count == 1 {
                let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onDoneSeletingContacts")
                button.tintColor = UIColor.whiteColor()
                navigationItem.rightBarButtonItem = button
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            if indexPaths.count == 0 {
                navigationItem.rightBarButtonItem = nil
            }
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            if searchText == "" {
                filteredContacts = Data.contacts
            } else {
                filteredContacts = Data.contacts.filter({ (user :Contact) -> Bool in
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
