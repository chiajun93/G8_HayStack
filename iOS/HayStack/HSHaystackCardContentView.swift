//
//  HSHaystackCardContentView.swift
//  HayStack
//
//  Created by Ian McDowell on 11/8/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit

class HSHaystackCardContentView: UIView {
    
    var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFontOfSize(28, weight: UIFontWeightLight)
        self.addSubview(titleLabel)
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.snp_leading).offset(15)
            make.trailing.equalTo(self.snp_trailing).offset(-15)
            make.top.equalTo(self.snp_top).offset(15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setupWithPost(post: HSPost) {
        titleLabel.text = post.text
    }
}
