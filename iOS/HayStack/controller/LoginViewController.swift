//
//  LoginViewController.swift
//  HayStack
//
//  Created by Nathanael Hardy on 9/25/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @IBAction func loginPressed(sender: AnyObject) {
        let trimmedUsername = usernameField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let password = passwordField.text!
        
        HSAPILoader.login(trimmedUsername, password: password) { (loggedIn, error) -> Void in
            if (loggedIn) {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                HSAPILoader.getUser(){ (success, error) -> Void in}
                
                appDelegate.showMainPage()
            } else {
                let alertController = UIAlertController(title: "Unable to login", message: error?.localizedDescription, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}

