//
//  TwitterClient.swift
//  WeGroup
//
//  Created by Darrell Shi on 2/11/16.
//  Copyright © 2016 WeGroup Inc. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

let twitterConsumerKey = "rVgalEXPwNas4IfhnEuVI0Uot"
let twitterConsumerSecret = "S2Eibi9NlffOruj7ByZIjouVF9FNbZ2bkbmLdIb1urZdJdYKvi"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    var loginComplition: ((user: User?, error: NSError?)->())?
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
    
    func loginWithComplition(complition: (user: User?, error: NSError?)->()) {
        loginComplition = complition
        // fetch request token and open url
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "kitchen.support://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("Successfully got the request token!")
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(authURL)
            }) { (error: NSError!) -> Void in
                print("Error getting request token")
                self.loginComplition?(user: nil, error: error)
        }
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken:BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Successfully got the access token!")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, progress: { (progress: NSProgress) -> Void in
                }, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                    //                    print("user: \(response)")
                    let user = User(dictionary: response as! NSDictionary)
                    User.currentUser = user
                    self.loginComplition?(user: user, error: nil)
                }, failure: { (operation: NSURLSessionDataTask?, error) -> Void in
                    print("Failed to get current user")
                    self.loginComplition?(user: nil, error: error)
            })
            }) { (error: NSError!) -> Void in
                print("Failed to get access token.")
                self.loginComplition?(user: nil, error: error)
        }
    }
}