//
//  CreateAccountViewController.swift
//  HayStack
//
//  Created by Nathanael Hardy on 9/25/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import Alamofire

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        self.confirmPasswordField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: AnyObject) {
      
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func createAccount(sender: AnyObject) {
        
        if (passwordField.text == confirmPasswordField.text && passwordField.text?.characters.count > 0) {
            print("Create" ,"Username:", self.usernameField.text, "Password:", self.passwordField.text)
            HSAPILoader.createAccount(self.usernameField.text, password: self.passwordField.text) { (success, error) -> Void in
                if (success) {
                    self.view.endEditing(true)
                    HSAPILoader.login(self.usernameField.text, password: self.passwordField.text) { (loggedIn, error) -> Void in
                        if (loggedIn) {
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.showMainPage()
                        } else {
                            let alertController = UIAlertController(title: "Unable to login", message: error?.localizedDescription, preferredStyle: .Alert)
                            alertController.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                } else {
                    print(error)
                    print("failed to sign up")
                    
                    let alertController = UIAlertController(title: "Unable to signup", message: error?.localizedDescription, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }else{
            let alertController = UIAlertController(title: "Invalid password", message: "Please ensure your passwords match", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            self.confirmPasswordField.becomeFirstResponder()
            self.passwordField.text = ""
            self.confirmPasswordField.text = ""
            
        }
    }
}
