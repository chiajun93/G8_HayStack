//
//  HomePageViewController.swift
//  HayStack
//
//  Created by Brad Patras on 10/14/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation



class HomePageViewController: UIViewController, HSHaystackViewDataSource, HSHaystackViewDelegate {
    
    @IBOutlet weak var refreshButton: UIButton!
    var haystackView: HSHaystackView!
    
    var posts = Array<HSPost>()
    
    override func viewDidLoad() {

        haystackView = HSHaystackView()
        haystackView.delegate = self
        haystackView.dataSource = self
        
        self.view.addSubview(haystackView)
        haystackView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view.snp_leading).offset(15)
            make.trailing.equalTo(self.view.snp_trailing).offset(-15)
            make.height.equalTo(haystackView.snp_width)
            make.centerY.equalTo(self.view.snp_centerY)
        }
        
        getPosts()
        
        self.view.bringSubviewToFront(self.refreshButton)
    }
    
    @IBAction func reloadButtonPressed(sender: AnyObject) {
        haystackView.alpha = 0
        haystackView.removeFromSuperview()
        haystackView = HSHaystackView()
        haystackView.delegate = self
        haystackView.dataSource = self
        
        self.view.addSubview(haystackView)
        haystackView.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view.snp_leading).offset(15)
            make.trailing.equalTo(self.view.snp_trailing).offset(-15)
            make.height.equalTo(haystackView.snp_width)
            make.centerY.equalTo(self.view.snp_centerY)
        }
        
        getPosts()
        
    }
    
    func haystackNumberOfCards(haystack: HSHaystackView) -> UInt {
        return UInt(self.posts.count)
    }
    
    func haystackViewForCardAtIndex(haystackView: HSHaystackView, index: UInt) -> UIView {
        let contentView = HSHaystackCardContentView()
        
        contentView.setupWithPost(self.posts[Int(index)])
        
        return contentView
    }
    
    func haystackViewForCardOverlayAtIndex(haystackView: HSHaystackView, index: UInt) -> HSHaystackCardOverlayView? {
        return HSHaystackCardOverlayView()
    }
    
    func haystackDidSwipedCardAtIndex(haystack: HSHaystackView, index: UInt, direction: HSHaystackViewSwipeDirection) {
        let post = self.posts[Int(index)]
        var voteAction: HSVoteAction!
        switch direction {
        case .Left:
            voteAction = .No
            break
        case .Right:
            voteAction = .Yes
            break
        case .None:
            return
        }
        
        HSAPILoader.vote(HSVote(action: voteAction, post: post)) { (vote, error) -> Void in
            print("Voted on post: \(post.text)")
        }
    }


    func getPosts(){
        self.posts = Array<HSPost>()
        
        HSAPILoader.getHomepagePosts { (posts, error) -> Void in
            if posts != nil {
                self.posts = posts!
            }
            
            self.haystackView.reloadData()
        }

        
    }
    
    
}
