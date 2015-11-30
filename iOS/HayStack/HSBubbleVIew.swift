//
//  HSBubbleVIew.swift
//  HayStack
//
//  Created by Nathanael Hardy on 11/27/15.
//  Copyright © 2015 309. All rights reserved.
//

import Foundation
import UIKit

class HSBubbleView: UIView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = self.frame.width/2;
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.5
        self.tintColor = UIColor.whiteColor()
        
        if (self.superview != nil){
            self.snp_makeConstraints { (make) -> Void in
                make.width.equalTo(self.superview!.frame.width/3 - 40)
                make.height.equalTo(self.superview!.frame.height/3 - 40)
                
            }
        }
        
    }
}