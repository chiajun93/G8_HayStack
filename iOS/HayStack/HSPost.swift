//
//  HSPost.swift
//  HayStack
//
//  Created by Nathanael Hardy on 10/14/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import CoreLocation

public class HSPost: NSObject {
    
    // Post ID
    var ID: Int!
    
    // Location
    var location: CLLocation!
    
    // Post Info
    var reward: Int!
    var text: String!
    var posterID: Int!
    
    //timing
    var posted: NSDate!
    var duration: Int!
    
    // Post Status (Active / Not Active)
    var status: Bool!
    
    override init() {
        super.init()
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        super.init()
        
        self.ID = dictionary["id"]?.integerValue
        
        self.text = dictionary["text"] as! String
    }

}
