//
//  SettingTable.swift
//  WeGroup
//
//  Created by Hanqi Du on 2/12/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class SettingTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBarHidden = false
        self.title = "Setting"
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.tableFooterView = UIView()
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            onLogout()
        }
    }
    
    
    
    private func onLogout() {
        if let twitterUser = User.currentUser {
            twitterUser.logOut()
            performSegueWithIdentifier("ToLogin", sender: nil)
        } else {
            PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
                if error == nil {
                    self.performSegueWithIdentifier("ToLogin", sender: nil)
                } else {
                    print("Failed to logout")
                }
            })
        }
    }
}

