//
//  ContactCell.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/26/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit
import Parse

class ContactCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    var user: PFUser? {
        didSet {
            usernameLabel.text = user?.username
            profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
            profileImageView.clipsToBounds = true
            profileImageView.layer.cornerRadius = 23
            if let profileData = user?["profile_image"] as? NSData {
                let image = UIImage(data: profileData)
                profileImageView.image = image
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
