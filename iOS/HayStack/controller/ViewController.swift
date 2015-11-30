//
//  ViewController.swift
//  HayStack
//
//  Created by Ian McDowell on 9/22/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateLocationText()
    }
    
    func updateLocationText() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.label.text = appDelegate.myLocation!.description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

