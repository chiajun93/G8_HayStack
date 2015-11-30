//
//  CreatePostViewController.swift
//  HayStack
//
//  Created by Ian McDowell on 10/15/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import SnapKit

class CreatePostViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var rewardStepper: UIStepper!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var postTextView: UITextField!
    
    
    var postText = ""
    var postReward = 1
    var postDuration = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        durationLabel.text = String(postDuration)
        rewardLabel.text = String(postReward)
        
        self.rewardStepper.minimumValue = 1
        self.rewardStepper.maximumValue = 20
        self.rewardStepper.stepValue = 5
        self.rewardStepper.wraps = true
        
        self.durationSlider.minimumValue = 1
        self.durationSlider.maximumValue = 24
        self.durationSlider.value = 1
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close() {
        //self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func stepperValueChanged(sender: AnyObject) {
        self.rewardLabel.text = String(Int(self.rewardStepper.value))
    }
    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        self.durationLabel.text = String(Int(self.durationSlider.value))
    }
    
    @IBAction func createPost() {
        let post = HSPost()
        
        post.text = self.postTextView.text
        post.reward = Int(self.rewardStepper.value)
        post.duration = Int(self.durationSlider.value * 60)
        post.location = (UIApplication.sharedApplication().delegate as! AppDelegate).myLocation!
        
        HSAPILoader.createPost(post) { (post, error) -> Void in
            if (post != nil) {
                print("Created post with ID: \(post!.ID), text: \(post!.text)")
                
                self.close()
            } else{
                
            }
        }
        self.clearFields()
    }

    func clearFields() {
        durationLabel.text = String(postDuration)
        rewardLabel.text = String(postReward)
        postTextView.text = ""
    }
    
    
}