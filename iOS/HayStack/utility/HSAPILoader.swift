//
//  HSAPILoader.swift
//  HayStack
//
//  Created by Ian McDowell on 10/15/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

let kAPIBaseURL = "http://proj-309-08.cs.iastate.edu"


let kAPILogout = "logout.php"
let kAPIGetUser = "getUser.php"
let kAPILogin = "login.php"
let kAPIcreateAccount = "createAccount.php"
let kAPICreatePost = "createPost.php"
let kAPIVote = "vote.php"
let kAPIActivePosts = "activePosts.php"


public class HSAPILoader: NSObject {
    
    public class func login(username: String!, password: String!, callback: (Bool, NSError?) -> Void) {
        createRequest(.POST, endpoint: kAPILogin, parameters: ["username": username, "password": password]).responseJSON(completionHandler: { (response) -> Void in
            
            if (response.response?.statusCode == 200) {
                callback(true, nil)
                print(response.result.value)
            } else {
                callback(false, response.result.error)
            }
        })
    }
    
    
    public class func createAccount(username: String!, password: String!, callback: (Bool, NSError?) -> Void) {
        createRequest(.POST, endpoint: kAPIcreateAccount, parameters: ["username": username, "password": password]).responseJSON(completionHandler: { (response) -> Void in
            if (response.response?.statusCode == 200) {
                callback(true, nil)
            } else {
                callback(false, response.result.error)
            }
        })
    }

    public class func createPost(post: HSPost!, callback: (HSPost?, NSError?) -> Void) {
        createRequest(.POST, endpoint: kAPICreatePost, parameters: ["text": post.text, "duration": post.duration, "reward": post.reward, "latitude": post.location.coordinate.latitude, "longitude": post.location.coordinate.longitude]).responseJSON { (response) -> Void in
            var post: HSPost?
            if (response.response?.statusCode == 200) {
                if let response = response.result.value as? Dictionary<String, AnyObject> {
                    post = HSPost(dictionary: response)
                }
            }
            callback(post, response.result.error)
        }
    }
    
    public class func getHomepagePosts(callback: (Array<HSPost>?, NSError?) -> Void) {
        createRequest(.GET, endpoint: kAPIActivePosts, parameters: nil).responseJSON { (response) -> Void in
            var posts = Array<HSPost>()
            if (response.result.isSuccess) {
                if let data = response.result.value as? Array<Dictionary<String, AnyObject>> {
                    for result in data {
                        print(result)
                        
                        let postText = result["text"] as! String
                        let postID = result["id"]!.integerValue
                        let post = HSPost()
                        post.text = postText
                        post.ID = postID
                        posts.append(post)
                    }
                }
            }
            callback(posts, nil)
        }
    }
    
    public class func getUser(callback: (Bool, NSError?) -> Void) {
        createRequest(.POST, endpoint: kAPIGetUser, parameters: nil).responseJSON(completionHandler: { (response) -> Void in
            if (response.response?.statusCode == 200) {
                callback(true, nil)
                print("success")
            } else {
                callback(false, response.result.error)
                print(response.result.value)
            }
        })
    }
    
    public class func logout() {
        createRequest(.POST, endpoint: kAPILogout, parameters: nil)
    }

    public class func vote(vote: HSVote, callback: (HSVote?, NSError?) -> Void) {
        createRequest(.POST, endpoint: kAPIVote, parameters: ["postID": vote.postID, "action":NSNumber(integer: vote.action.rawValue)]).responseJSON { (response) -> Void in
            
            var vote: HSVote?
            if (response.response?.statusCode == 200) {
                if let response = response.result.value as? Dictionary<String, AnyObject> {
                    vote = HSVote(dictionary: response)
                }
            }
            callback(vote, response.result.error)
            
       
        }
    }
    
    private class func createRequest(method: Alamofire.Method, endpoint: String, parameters: [String: AnyObject]?) -> Request {
        return Alamofire.request(method, "\(kAPIBaseURL)/\(endpoint)", parameters: parameters)
    }
}
