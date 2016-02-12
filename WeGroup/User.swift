//
//  User.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/11/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation

var _currentUser: User?
let currentUserKey = "currentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User {
    var name: String?
    var profileURL: String?
    var dictionary: NSDictionary?
    // TODO: add more
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        profileURL = dictionary["profile_image_url_https"] as? String
    }
    
    class var currentUser: User? {
        get {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData {
        do {
        let data = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
        User.currentUser = User(dictionary: data)
    } catch {
        print("Failed getting JSON object with data")
        }
        }
        
        return _currentUser
        }
        
        set(user) {
            _currentUser = user
            if user != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject((user?.dictionary)!, options: NSJSONWritingOptions(rawValue: 0))
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch {
                    print("Failed getting data with JSON object")
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func logOut() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
}