//
//  MessageCell.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/4/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    var message: Message! {
        didSet {
            profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
            profileImageView.clipsToBounds = true
            profileImageView.layer.cornerRadius = 23
            if let profileData = message.from.profileImageData {
                let image = UIImage(data: profileData)
                profileImageView.image = image
            }
            usernameLabel.text = message.from.username
            messageTextLabel.text = message.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
