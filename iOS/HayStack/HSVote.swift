//
//  HSVote.swift
//  HayStack
//
//  Created by Nathanael Hardy on 10/14/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit

public enum HSVoteAction: NSInteger {
    case No = -1
    case Yes = 1
}

public class HSVote: NSObject {
    
    // Vote ID
    var ID: Int!
    
    // Post ID of the post voted on
    var postID: Int!
    
    // Voter ID
    var userID: Int!
    
    //
    var action: HSVoteAction!

    init(dictionary: Dictionary<String, AnyObject>) {
        super.init()
        
        self.ID = dictionary["id"]?.integerValue
        
        self.postID = dictionary["postID"]?.integerValue
        
    }
    
    init(action: HSVoteAction, post: HSPost) {
        super.init()
        
        self.action = action
        self.postID = post.ID
    }
    
    override init() {
        super.init()
    }
    
    
}
