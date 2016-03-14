//
//  ConversationCell.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/4/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Foundation

class ConversationCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var notificationView: UIView!
    
    var conversation: Conversation! {
        didSet {
            let toUsers = Array(conversation.toUsers) as! [Contact]
            
            var username = ""
            for index in 0...conversation.toUsers.count-1 {
                username += "\(toUsers[index].username)"
                if index != conversation.toUsers.count-1 {
                    username += ", "
                }
            }
            usernameLabel.text = username
            
            if let lastMessage = conversation.messages.lastObject as? Message {
                previewLabel.text = lastMessage.text
            } else {
                previewLabel.text = ""
            }
            
            profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
            profileImageView.clipsToBounds = true
            profileImageView.layer.cornerRadius = 25
            if conversation.isGroupChat {
//                profileImageView.backgroundColor = conversation.profileColor
            } else {
                if let profileData = toUsers.first?.profileImageData {
                    let image = UIImage(data: profileData)
                    profileImageView.image = image
                }
            }
            
            if let time = conversation?.updatedAt{
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm"
                let dateString = dateFormatter.stringFromDate(time)
                timeLabel.text = dateString
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
