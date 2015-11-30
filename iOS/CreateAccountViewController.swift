//
//  CreateAccountViewController.swift
//  HayStack
//
//  Created by Nathanael Hardy on 9/25/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import Alamofire

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createAccount(sender: AnyObject) {
        
        if (passwordField.text == confirmPasswordField.text) {
            print("Create" ,"Username:", self.usernameField.text, "Password:", self.passwordField.text)
            
        }
    }
}
