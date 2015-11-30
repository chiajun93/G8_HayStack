//
//  HSBorderedButton.swift
//  HayStack
//
//  Created by Nathanael Hardy on 11/7/15.
//  Copyright © 2015 309. All rights reserved.
//

import Foundation
import UIKit

class HSBorderedButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 8.0;
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.5
        self.tintColor = UIColor.whiteColor()
        
    }
}