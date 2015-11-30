//
//  ProfileViewController.swift
//  HayStack
//
//  Created by Nathanael Hardy on 11/8/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBAction func signOut(sender: AnyObject) {
        
        //logOut
        HSAPILoader.logout()
        
        //show login Page
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.showLoginPage()

        
    }

}
