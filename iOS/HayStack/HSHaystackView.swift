//
//  HSHaystackView.swift
//  HayStack
//
//  Created by Ian McDowell on 10/29/15.
//  Copyright © 2015 309. All rights reserved.
//

import UIKit
import pop

public enum HSHaystackViewSwipeDirection {
    case None
    case Left
    case Right
}

//Default values
private let defaultCountOfVisibleCards = 3
private let backgroundCardsTopMargin: CGFloat = 4.0
private let backgroundCardsScalePercent: CGFloat = 0.95
private let backgroundCardsLeftMargin: CGFloat = 8.0

//Animations constants
private let revertCardAnimationName = "revertCardAlphaAnimation"
private let revertCardAnimationDuration: NSTimeInterval = 1.0
private let revertCardAnimationToValue: CGFloat = 1.0
private let revertCardAnimationFromValue: CGFloat = 0.0

private let haystackAppearScaleAnimationName = "haystackAppearScaleAnimation"
private let haystackAppearScaleAnimationFromValue = CGPoint(x: 0.1, y: 0.1)
private let haystackAppearScaleAnimationToValue = CGPoint(x: 1.0, y: 1.0)
private let haystackAppearScaleAnimationDuration: NSTimeInterval = 0.8
private let haystackAppearAlphaAnimationName = "haystackAppearAlphaAnimation"
private let haystackAppearAlphaAnimationFromValue: CGFloat = 0.0
private let haystackAppearAlphaAnimationToValue: CGFloat = 1.0
private let haystackAppearAlphaAnimationDuration: NSTimeInterval = 0.8


public protocol HSHaystackViewDataSource: class {
    
    func haystackNumberOfCards(haystack: HSHaystackView) -> UInt
    func haystackViewForCardAtIndex(haystack: HSHaystackView, index: UInt) -> UIView
    func haystackViewForCardOverlayAtIndex(haystack: HSHaystackView, index: UInt) -> HSHaystackCardOverlayView?
    
}

public protocol HSHaystackViewDelegate: class {
    func haystackDidSwipedCardAtIndex(haystack: HSHaystackView,index: UInt, direction: HSHaystackViewSwipeDirection)
    func haystackDidRunOutOfCards(haystack: HSHaystackView)
    func haystackDidSelectCardAtIndex(haystack: HSHaystackView, index: UInt)
    func haystackDraggedCard(haystack: HSHaystackView, finishPercent: CGFloat, direction: HSHaystackViewSwipeDirection)
}

public extension HSHaystackViewDelegate {
    func haystackDidSwipedCardAtIndex(haystack: HSHaystackView,index: UInt, direction: HSHaystackViewSwipeDirection) {}
    func haystackDidRunOutOfCards(haystack: HSHaystackView) {}
    func haystackDidSelectCardAtIndex(haystack: HSHaystackView, index: UInt) {}
    func haystackDraggedCard(haystack: HSHaystackView, finishPercent: CGFloat, direction: HSHaystackViewSwipeDirection) {}
}

public class HSHaystackView: UIView, HSHaystackCardViewDelegate {
    
    public weak var dataSource: HSHaystackViewDataSource! {
        didSet {
            setupDeck()
        }
    }
    public weak var delegate: HSHaystackViewDelegate?
    
    private(set) public var currentCardNumber = 0
    private(set) public var countOfCards = 0
    
    public var countOfVisibleCards = defaultCountOfVisibleCards
    private var visibleCards = [HSHaystackCardView]()
    private var animating = false
    private var configured = false
    
    //MARK: Lifecycle
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    deinit {
        unsubsribeFromNotifications()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if !self.configured {
            
            if self.visibleCards.isEmpty {
                reloadData()
            } else {
                layoutDeck()
            }
            
            self.configured = true
        }
    }
    
    //MARK: Configurations
    
    private func subscribeForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "layoutDeck", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    private func unsubsribeFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func configure() {
        subscribeForNotifications()
    }
    
    private func setupDeck() {
        countOfCards = Int(dataSource!.haystackNumberOfCards(self))
        
        if countOfCards - currentCardNumber > 0 {
            
            let countOfNeededCards = min(countOfVisibleCards, countOfCards - currentCardNumber)
            
            for index in 0..<countOfNeededCards {
                if let nextCardContentView = dataSource?.haystackViewForCardAtIndex(self, index: UInt(index+currentCardNumber)) {
                    let nextCardView = HSHaystackCardView(frame: frameForCardAtIndex(UInt(index)))
                    
                    nextCardView.delegate = self
                    nextCardView.alpha = 1
                    nextCardView.userInteractionEnabled = index == 0
                    
                    let overlayView = overlayViewForCardAtIndex(UInt(index+currentCardNumber))
                    
                    nextCardView.configure(nextCardContentView, overlayView: overlayView)
                    visibleCards.append(nextCardView)
                    index == 0 ? addSubview(nextCardView) : insertSubview(nextCardView, belowSubview: visibleCards[index - 1])
                }
            }
        }
    }
    
    public func layoutDeck() {
        for (index, card) in self.visibleCards.enumerate() {
            card.frame = frameForCardAtIndex(UInt(index))
        }
    }
    
    //MARK: Frames
    public func frameForCardAtIndex(index: UInt) -> CGRect {
        let bottomOffset:CGFloat = 0
        let topOffset = backgroundCardsTopMargin * CGFloat(self.countOfVisibleCards - 1)
        let scalePercent = backgroundCardsScalePercent
        let width = CGRectGetWidth(self.frame) * pow(scalePercent, CGFloat(index))
        let xOffset = (CGRectGetWidth(self.frame) - width) / 2
        let height = (CGRectGetHeight(self.frame) - bottomOffset - topOffset) * pow(scalePercent, CGFloat(index))
        let multiplier: CGFloat = index > 0 ? 1.0 : 0.0
        let previousCardFrame = index > 0 ? frameForCardAtIndex(max(index - 1, 0)) : CGRectZero
        let yOffset = (CGRectGetHeight(previousCardFrame) - height + previousCardFrame.origin.y + backgroundCardsTopMargin) * multiplier
        let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        
        return frame
    }
    
    private func moveOtherCardsWithFinishPercent(percent: CGFloat) {
        if visibleCards.count > 1 {
            
            for index in 1..<visibleCards.count {
                let previousCardFrame = frameForCardAtIndex(UInt(index - 1))
                var frame = frameForCardAtIndex(UInt(index))
                let distanceToMoveY: CGFloat = (frame.origin.y - previousCardFrame.origin.y) * (percent / 100)
                
                frame.origin.y -= distanceToMoveY
                
                let distanceToMoveX: CGFloat = (previousCardFrame.origin.x - frame.origin.x) * (percent / 100)
                
                frame.origin.x += distanceToMoveX
                
                let widthScale = (previousCardFrame.size.width - frame.size.width) * (percent / 100)
                let heightScale = (previousCardFrame.size.height - frame.size.height) * (percent / 100)
                
                frame.size.width += widthScale
                frame.size.height += heightScale
                
                let card = visibleCards[index]
                
                card.pop_removeAllAnimations()
                card.frame = frame
                card.layoutIfNeeded()
                
                card.alpha = 1
            }
        }
    }
    
    //MARK: Animations
    
    public func applyAppearAnimation() {
        userInteractionEnabled = false
        animating = true
        
        let haystackAppearScaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        
        haystackAppearScaleAnimation.beginTime = CACurrentMediaTime() + cardSwipeActionAnimationDuration
        haystackAppearScaleAnimation.duration = haystackAppearScaleAnimationDuration
        haystackAppearScaleAnimation.fromValue = NSValue(CGPoint: haystackAppearScaleAnimationFromValue)
        haystackAppearScaleAnimation.toValue = NSValue(CGPoint: haystackAppearScaleAnimationToValue)
        haystackAppearScaleAnimation.completionBlock = {
            (_, _) in
            
            self.userInteractionEnabled = true
            self.animating = false
        }
        
        let haystackAppearAlphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        
        haystackAppearAlphaAnimation.beginTime = CACurrentMediaTime() + cardSwipeActionAnimationDuration
        haystackAppearAlphaAnimation.fromValue = NSNumber(float: Float(haystackAppearAlphaAnimationFromValue))
        haystackAppearAlphaAnimation.toValue = NSNumber(float: Float(haystackAppearAlphaAnimationToValue))
        haystackAppearAlphaAnimation.duration = haystackAppearAlphaAnimationDuration
        
        pop_addAnimation(haystackAppearAlphaAnimation, forKey: haystackAppearAlphaAnimationName)
        pop_addAnimation(haystackAppearScaleAnimation, forKey: haystackAppearScaleAnimationName)
    }
    
    func applyRevertAnimation(card: HSHaystackCardView) {
        animating = true
        
        let firstCardAppearAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        
        firstCardAppearAnimation.toValue = NSNumber(float: Float(revertCardAnimationToValue))
        firstCardAppearAnimation.fromValue =  NSNumber(float: Float(revertCardAnimationFromValue))
        firstCardAppearAnimation.duration = revertCardAnimationDuration
        firstCardAppearAnimation.completionBlock = {
            (_, _) in
            
            self.animating = false
        }
        
        card.pop_addAnimation(firstCardAppearAnimation, forKey: revertCardAnimationName)
    }
    
    //MARK: HSHaystackCardViewDelegate
    
    func cardDraggedWithFinishPercent(card: HSHaystackCardView, percent: CGFloat, direction: HSHaystackViewSwipeDirection) {
        animating = true
        
        self.moveOtherCardsWithFinishPercent(percent)
        delegate?.haystackDraggedCard(self, finishPercent: percent, direction: direction)
    }
    
    func cardSwippedInDirection(card: HSHaystackCardView, direction: HSHaystackViewSwipeDirection) {
        swipedAction(direction)
    }
    
    func cardWasReset(card: HSHaystackCardView) {
        if visibleCards.count > 1 {
            
            UIView.animateWithDuration(0.2,
                delay: 0.0,
                options: .CurveLinear,
                animations: {
                    self.moveOtherCardsWithFinishPercent(0)
                },
                completion: {
                    _ in
                    self.animating = false
                    
                    for index in 1..<self.visibleCards.count {
                        let card = self.visibleCards[index]
                        card.alpha = 1
                    }
            })
        } else {
            animating = false
        }
        
    }
    
    func cardTapped(card: HSHaystackCardView) {
        let index = currentCardNumber + visibleCards.indexOf(card)!
        
        delegate?.haystackDidSelectCardAtIndex(self, index: UInt(index))
    }
    
    //MARK: Private
    
    private func clear() {
        currentCardNumber = 0
        
        for card in visibleCards {
            card.removeFromSuperview()
        }
        
        visibleCards.removeAll(keepCapacity: true)
        
    }
    
    private func overlayViewForCardAtIndex(index: UInt) -> HSHaystackCardOverlayView? {
        return dataSource.haystackViewForCardOverlayAtIndex(self, index: index)
    }
    
    //MARK: Actions
    
    private func swipedAction(direction: HSHaystackViewSwipeDirection) {
        animating = true
        visibleCards.removeAtIndex(0)
        
        currentCardNumber++
        let shownCardsCount = currentCardNumber + countOfVisibleCards
        if shownCardsCount - 1 < countOfCards {
            
            if let dataSource = self.dataSource {
                
                let lastCardContentView = dataSource.haystackViewForCardAtIndex(self, index: UInt(shownCardsCount - 1))
                let lastCardOverlayView = dataSource.haystackViewForCardOverlayAtIndex(self, index: UInt(shownCardsCount - 1))
                let lastCardFrame = frameForCardAtIndex(UInt(currentCardNumber + visibleCards.count))
                let lastCardView = HSHaystackCardView(frame: lastCardFrame)
                
                lastCardView.hidden = true
                lastCardView.userInteractionEnabled = true
                
                lastCardView.configure(lastCardContentView, overlayView: lastCardOverlayView)
                
                lastCardView.delegate = self
                
                if let lastCard = visibleCards.last {
                    insertSubview(lastCardView, belowSubview:lastCard)
                } else {
                    addSubview(lastCardView)
                }
                visibleCards.append(lastCardView)
            }
        }
        
        if !visibleCards.isEmpty {
            
            for (index, currentCard) in visibleCards.enumerate() {
                let frameAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
                    frameAnimation.duration = 0.2
                
                currentCard.alpha = 1
                
                if index == 0 {
                    frameAnimation.completionBlock = {(_, _) in
                        self.visibleCards.last?.hidden = false
                        self.animating = false
                        self.delegate?.haystackDidSwipedCardAtIndex(self, index: UInt(self.currentCardNumber - 1), direction: direction)
                    }
                }
                
                currentCard.userInteractionEnabled = index == 0
                frameAnimation.toValue = NSValue(CGRect: frameForCardAtIndex(UInt(index)))
                
                currentCard.pop_addAnimation(frameAnimation, forKey: "frameAnimation")
            }
        } else {
            delegate?.haystackDidSwipedCardAtIndex(self, index: UInt(currentCardNumber - 1), direction: direction)
            animating = false
            self.delegate?.haystackDidRunOutOfCards(self)
        }
        
    }
    
    private func loadMissingCards(missingCardsCount: Int) {
        if missingCardsCount > 0 {
            
            let cardsToAdd = min(missingCardsCount, countOfCards - currentCardNumber)
            
            for index in 1...cardsToAdd {
                let nextCardView = HSHaystackCardView(frame: frameForCardAtIndex(UInt(index)))
                
                nextCardView.alpha = 1
                nextCardView.delegate = self
                
                visibleCards.append(nextCardView)
                insertSubview(nextCardView, belowSubview: visibleCards[index - 1])
            }
        }
        
        reconfigureCards()
    }
    
    private func reconfigureCards() {
        for index in 0..<visibleCards.count {
            if let dataSource = self.dataSource {
                
                let currentCardContentView = dataSource.haystackViewForCardAtIndex(self, index: UInt(currentCardNumber + index))
                let overlayView = dataSource.haystackViewForCardOverlayAtIndex(self, index: UInt(currentCardNumber + index))
                let currentCard = visibleCards[index]
                
                currentCard.configure(currentCardContentView, overlayView: overlayView)
            }
        }
    }
    
    public func reloadData() {
        countOfCards = Int(dataSource!.haystackNumberOfCards(self))
        let missingCards = min(countOfVisibleCards - visibleCards.count, countOfCards - (currentCardNumber + 1))
        
        if countOfCards == 0 {
            return
        }
        
        if currentCardNumber == 0 {
            clear()
        }
        
        if countOfCards - (currentCardNumber + visibleCards.count) > 0 {
            
            if !visibleCards.isEmpty {
                loadMissingCards(missingCards)
            } else {
                setupDeck()
                layoutDeck()
                
                self.alpha = 0
                applyAppearAnimation()
            }
            
        } else {
            
            reconfigureCards()
        }
    }
    
    public func swipe(direction: HSHaystackViewSwipeDirection) {
        if (animating == false) {
            
            if let frontCard = visibleCards.first {
                
                animating = true
                
                switch direction {
                case .None:
                    return
                case .Left:
                    frontCard.swipeLeft()
                case .Right:
                    frontCard.swipeRight()
                }
            }
        }
    }
    
    public func resetCurrentCardNumber() {
        clear()
        reloadData()
    }
    
    public func viewForCardAtIndex(index: Int) -> UIView? {
        if visibleCards.count + currentCardNumber > index && index >= currentCardNumber {
            return visibleCards[index - currentCardNumber].contentView
        } else {
            return nil
        }
    }
}
