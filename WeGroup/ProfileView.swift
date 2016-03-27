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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
    var contact: Contact!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameLabel.text = contact.username
        if let profileData = contact.profileImageData {
            profileImageView.image = UIImage(data: profileData)
        }
        regionLabel.text = contact.region
        shortBioLabel.text = contact.shortBio
    }
    
    override func viewWillLayoutSubviews() {
        contentViewWidthConstraint.constant = UIScreen.mainScreen().bounds.size.width

        super.viewWillLayoutSubviews()
        
        contentViewHeightConstraint.constant = scrollView.frame.size.height+50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
