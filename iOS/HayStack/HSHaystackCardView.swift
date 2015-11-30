//
//  HSHaystackCardView.swift
//  HayStack
//
//  Created by Ian McDowell on 10/29/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import pop

protocol HSHaystackCardViewDelegate: class {
    
    func cardDraggedWithFinishPercent(card: HSHaystackCardView, percent: CGFloat, direction: HSHaystackViewSwipeDirection)
    func cardSwippedInDirection(card: HSHaystackCardView, direction: HSHaystackViewSwipeDirection)
    func cardWasReset(card: HSHaystackCardView)
    func cardTapped(card: HSHaystackCardView)
    
}

//Drag animation constants
private let rotationMax: CGFloat = 1.0
private let defaultRotationAngle = CGFloat(M_PI) / 10.0
private let scaleMin: CGFloat = 0.8
public let cardSwipeActionAnimationDuration: NSTimeInterval  = 0.4

//Reset animation constants
private let cardResetAnimationSpringBounciness: CGFloat = 10.0
private let cardResetAnimationSpringSpeed: CGFloat = 20.0
private let cardResetAnimationKey = "resetPositionAnimation"
private let cardResetAnimationDuration: NSTimeInterval = 0.2

public class HSHaystackCardView: UIView {
    
    weak var delegate: HSHaystackCardViewDelegate?
    
    private var overlayView: HSHaystackCardOverlayView?
    private(set) var contentView: UIView?
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var originalLocation: CGPoint = CGPoint(x: 0.0, y: 0.0)
    private var animationDirection: CGFloat = 1.0
    private var dragBegin = false
    private var xDistanceFromCenter: CGFloat = 0.0
    private var yDistanceFromCenter: CGFloat = 0.0
    private var actionMargin: CGFloat = 0.0
    private var firstTouch = true
    
    //MARK: Lifecycle
    init() {
        super.init(frame: CGRectZero)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override public var frame: CGRect {
        didSet {
            actionMargin = frame.size.width / 2.0
        }
    }
    
    deinit {
        removeGestureRecognizer(panGestureRecognizer)
        removeGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setup() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panGestureRecognized:"))
        addGestureRecognizer(panGestureRecognizer)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapRecognized:"))
        addGestureRecognizer(tapGestureRecognizer)
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.borderWidth = 1
        
        self.clipsToBounds = true
    }
    
    //MARK: Configurations
    func configure(view: UIView, overlayView: HSHaystackCardOverlayView?) {
        self.overlayView?.removeFromSuperview()
        
        if let overlay = overlayView {
            self.overlayView = overlay
            overlay.alpha = 0;
            self.addSubview(overlay)
            configureOverlayView()
            self.insertSubview(view, belowSubview: overlay)
        } else {
            self.addSubview(view)
        }
        
        self.contentView?.removeFromSuperview()
        self.contentView = view
        configureContentView()
    }
    
    private func configureOverlayView() {
        if let overlay = self.overlayView {
            overlay.translatesAutoresizingMaskIntoConstraints = false
            
            overlay.snp_makeConstraints(closure: { (make) -> Void in
                make.width.equalTo(self.snp_width)
                make.height.equalTo(self.snp_height)
                make.top.equalTo(self.snp_top)
                make.leading.equalTo(self.snp_leading)
            })

        }
    }
    
    private func configureContentView() {
        if let contentView = self.contentView {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.snp_makeConstraints(closure: { (make) -> Void in
                make.width.equalTo(self.snp_width)
                make.height.equalTo(self.snp_height)
                make.top.equalTo(self.snp_top)
                make.leading.equalTo(self.snp_leading)
            })
        }
    }
    
    //MARK: GestureRecozniers
    
    func panGestureRecognized(gestureRecognizer: UIPanGestureRecognizer) {
        xDistanceFromCenter = gestureRecognizer.translationInView(self).x
        yDistanceFromCenter = gestureRecognizer.translationInView(self).y
        
        let touchLocation = gestureRecognizer.locationInView(self)
        
        switch gestureRecognizer.state {
        case .Began:
            if firstTouch {
                originalLocation = center
                firstTouch = false
            }
            dragBegin = true
            
            animationDirection = touchLocation.y >= frame.size.height / 2 ? -1.0 : 1.0
            
            layer.shouldRasterize = true
            
            pop_removeAllAnimations()
            break
        case .Changed:
            let rotationStrength = min(xDistanceFromCenter / self.frame.size.width, rotationMax)
            let rotationAngle = animationDirection * defaultRotationAngle * rotationStrength
            let scaleStrength = 1 - ((1 - scaleMin) * fabs(rotationStrength))
            let scale = max(scaleStrength, scaleMin)
            
            layer.rasterizationScale = scale * UIScreen.mainScreen().scale
            
            let transform = CGAffineTransformMakeRotation(rotationAngle)
            let scaleTransform = CGAffineTransformScale(transform, scale, scale)
            
            self.transform = scaleTransform
            center = CGPoint(x: originalLocation.x + xDistanceFromCenter, y: originalLocation.y + yDistanceFromCenter)
            
            updateOverlayWithFinishPercent(xDistanceFromCenter / frame.size.width)
            //100% - for proportion
            var dragDirection = HSHaystackViewSwipeDirection.None
            dragDirection = xDistanceFromCenter > 0 ? .Right : .Left
            delegate?.cardDraggedWithFinishPercent(self, percent: min(fabs(xDistanceFromCenter * 100 / frame.size.width), 100), direction: dragDirection)
            
            break
        case .Ended:
            swipeMadeAction()
            
            layer.shouldRasterize = false
        default :
            break
        }
    }
    
    func tapRecognized(recogznier: UITapGestureRecognizer) {
        delegate?.cardTapped(self)
    }
    
    //MARK: Private
    private func updateOverlayWithFinishPercent(percent: CGFloat) {
        if let overlayView = self.overlayView {
            overlayView.overlayState = percent > 0.0 ? .Right : .Left
            //Overlay is fully visible on half way
            let overlayStrength = min(fabs(2 * percent), 1.0)
            overlayView.alpha = overlayStrength
        }
    }
    
    private func swipeMadeAction() {
        if xDistanceFromCenter > actionMargin {
            rightAction()
        } else if xDistanceFromCenter < -actionMargin {
            leftAction()
        } else {
            resetViewPositionAndTransformations()
        }
    }
    
    private func rightAction() {
        let finishY = originalLocation.y + yDistanceFromCenter
        let finishPoint = CGPoint(x: CGRectGetWidth(UIScreen.mainScreen().bounds) * 2, y: finishY)
        
        self.overlayView?.overlayState = .Right
        self.overlayView?.alpha = 1.0
        self.delegate?.cardSwippedInDirection(self, direction: .Right)
        UIView.animateWithDuration(cardSwipeActionAnimationDuration,
            delay: 0.0,
            options: .CurveLinear,
            animations: {
                self.center = finishPoint
                
            },
            completion: {
                _ in
                
                self.dragBegin = false
                self.removeFromSuperview()
        })
    }
    
    private func leftAction() {
        let finishY = originalLocation.y + yDistanceFromCenter
        let finishPoint = CGPoint(x: -CGRectGetWidth(UIScreen.mainScreen().bounds), y: finishY)
        
        self.overlayView?.overlayState = .Left
        self.overlayView?.alpha = 1.0
        self.delegate?.cardSwippedInDirection(self, direction: .Left)
        UIView.animateWithDuration(cardSwipeActionAnimationDuration,
            delay: 0.0,
            options: .CurveLinear,
            animations: {
                self.center = finishPoint
                
            },
            completion: {
                _ in
                
                self.dragBegin = false
                self.removeFromSuperview()
        })
    }
    
    private func resetViewPositionAndTransformations() {
        self.delegate?.cardWasReset(self)
        
        let resetPositionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
        
        resetPositionAnimation.toValue = NSValue(CGPoint: originalLocation)
        resetPositionAnimation.springBounciness = cardResetAnimationSpringBounciness
        resetPositionAnimation.springSpeed = cardResetAnimationSpringSpeed
        resetPositionAnimation.completionBlock = {
            (_, _) in
            
            self.dragBegin = false
        }
        
        pop_addAnimation(resetPositionAnimation, forKey: cardResetAnimationKey)
        
        UIView.animateWithDuration(cardResetAnimationDuration,
            delay: 0.0,
            options: [.CurveLinear, .AllowUserInteraction],
            animations: {
                self.transform = CGAffineTransformMakeRotation(0)
                self.overlayView?.alpha = 0
                self.layoutIfNeeded()
                
                return
            },
            completion: {
                _ in
                
                self.transform = CGAffineTransformIdentity
                
                return
        })
    }
    
    //MARK: Public
    
    func swipeLeft () {
        if !dragBegin {
            
            let finishPoint = CGPoint(x: -CGRectGetWidth(UIScreen.mainScreen().bounds), y: center.y)
            self.delegate?.cardSwippedInDirection(self, direction: .Left)
            UIView.animateWithDuration(cardSwipeActionAnimationDuration,
                delay: 0.0,
                options: .CurveLinear,
                animations: {
                    self.center = finishPoint
                    self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_4))
                    
                    return
                },
                completion: {
                    _ in
                    
                    self.removeFromSuperview()
                    
                    return
            })
        }
    }
    
    func swipeRight () {
        if !dragBegin {
            
            let finishPoint = CGPoint(x: CGRectGetWidth(UIScreen.mainScreen().bounds) * 2, y: center.y)
            self.delegate?.cardSwippedInDirection(self, direction: .Right)
            UIView.animateWithDuration(cardSwipeActionAnimationDuration, delay: 0.0, options: .CurveLinear, animations: {
                self.center = finishPoint
                self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
                
                return
                },
                completion: {
                    _ in
                    
                    self.removeFromSuperview()
                    
                    return
            })
        }
    }
}


public enum HSHaystackCardOverlayViewMode {
    case None
    case Left
    case Right
}


public class HSHaystackCardOverlayView: UIView {
    
    lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .Center
        imageView.tintColor = UIColor.whiteColor()
        self.addSubview(imageView)
        
        return imageView
    }()
    
    public var overlayState: HSHaystackCardOverlayViewMode = .None {
        didSet {
            switch overlayState {
            case .Left :
                overlayImageView.image = UIImage(named: "no")
                self.backgroundColor = UIColor.redColor()
            case .Right :
                overlayImageView.image = UIImage(named: "yes")
                self.backgroundColor = UIColor(red: 19/255.0, green: 143/255.0, blue: 23/255.0, alpha: 1)
            default:
                overlayImageView.image = nil
                self.backgroundColor = nil
            }
            
        }
    }
    
}