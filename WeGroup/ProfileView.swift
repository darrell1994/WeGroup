//
//  ProfileView.swift
//  WeGroup
//
//  Created by Darrell Shi on 3/15/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import UIKit

class ProfileView: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var shortBioLabel: UILabel!
    var contact: Contact!

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLabel.text = contact.username
        if let profileData = contact.profileImageData {
            profileImageView.image = UIImage(data: profileData)
        } else {
            if let red = contact.red, green = contact.green, blue = contact.blue {
                profileImageView.backgroundColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 0.5)
            }
        }
        regionLabel.text = contact.region
        shortBioLabel.text = contact.shortBio
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
