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
let didReceiveNewMessage = "didReceiveNewMessage"

class ConversationsView: UIViewController {
    @IBOutlet var tableView: UITableView!
    var deleting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "onTimer", userInfo: nil, repeats: true)
        
        Data.checkNewContacts(nil)
        onTimer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onTimer() {
        Data.checkNewMessages { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onAddConversation(sender: AnyObject) {
        self.performSegueWithIdentifier("ToContactPicker", sender: nil)
    }
    
    @IBAction func onEdit(sender: AnyObject) {
//        deleting = true
        let numberOfRows = tableView.numberOfRowsInSection(0)
        let gesture = UITapGestureRecognizer(target: self, action: "onDeleteConversation:")
        for row in 0...numberOfRows-1 {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))!
            let origin = cell.contentView.frame.origin
            let deleteView = UIImageView(frame: CGRect(x: -20, y: 25, width: 20, height: 20))
            deleteView.image = UIImage(named: "delete_button")
            deleteView.userInteractionEnabled = true
            deleteView.addGestureRecognizer(gesture)
            cell.contentView.addSubview(deleteView)
            
            UIView.animateWithDuration(0.3) { () -> Void in
                cell.contentView.frame.origin = CGPoint(x: origin.x+30, y: origin.y)
            }
        }
    }
    
    func onDeleteConversation(gesture: UITapGestureRecognizer) {
        gesture.view?.backgroundColor = UIColor.blackColor()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToChat" {
            let cell = sender as! ConversationCell
            let indexPath = tableView.indexPathForCell(cell)
            let vc = segue.destinationViewController as! MessageView
            vc.conversation = Data.conversations[indexPath!.row]
        }
    }
}

extension ConversationsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell") as! ConversationCell
        cell.conversation = Data.conversations[indexPath.row]
        return cell
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        <#code#>
//    }
}
