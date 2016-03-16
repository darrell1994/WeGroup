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
            profileImageView.backgroundColor = UIColor(red: 164/265, green: 198/265, blue: 99/265, alpha: 1)
        }
        regionLabel.text = contact.region
        shortBioLabel.text = contact.shortBio
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
