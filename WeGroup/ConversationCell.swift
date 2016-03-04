//
//  ConversationCell.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/4/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var conversation: Conversation? {
        didSet {
            usernameLabel.text = conversation?.toUsers.first?.username
            if let preview = conversation?.messages.last?.text {
                previewLabel.text = preview
            } else {
                previewLabel.text = ""
            }
            profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
            profileImageView.clipsToBounds = true
            profileImageView.layer.cornerRadius = 25
            if let profileData = conversation?.toUsers.first?["profile_image"] as? NSData {
                let image = UIImage(data: profileData)
                profileImageView.image = image
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
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
