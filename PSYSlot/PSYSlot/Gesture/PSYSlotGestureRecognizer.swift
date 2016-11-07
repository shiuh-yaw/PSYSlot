//
//  PSYSlotGestureRecognizer.swift
//  PSYSlot
//
//  Created by Shiuh Yaw Phang on 07/11/2016.
//  Copyright © 2016 Shiuh Yaw Phang. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum PSYBorderType: Int {
    case none
    case left
    case right
    case top
    case bottom
}

class PSYSlotGestureRecognizer: UIGestureRecognizer {
    
    let kSpeedMultiplier: CGFloat = 0.2
    let kSecond: CGFloat = 60.0
    let kTolerence:CGFloat = 25.0
    let kExtended:CGFloat = 25.0
    
    // This minimum required duration the user has to press donw on the view to start the gesture.
    // The default value is 0.5 seconds, similar to UILongPressGestureRecognizer.
    public var minimumPressDuration: TimeInterval = 0.5
    
    // The required distance in points the user has to move his finger to start the drag gesture.
    // The default value is 0 points
    public var minimumMovement: CGFloat = 0
    
    // The maximum distance in points the user is allowed to move his finger while presenting down on the view (before the gesture is started)
    // The default value is 10 points, similar to UILongPressGestureRecognizer
    public var maximumMovement: CGFloat = 10
    
    // A rectangle in the gesture recognizer's view's coordinate system. Touches outside of this frame will be ignored.
    public var frame: CGRect {
        get {
            guard let v = view else {
                return CGRect.zero
            }
            return v.bounds
        }
    }
    
    // The scroll view that should be auto-scrolled by the gesture the finger move tot he edges of the scroll view
    public var scrollView: UIScrollView {
        get {
            return self.enclosingScrollView()!
        }
    }
    
    // Determines whether auto-scrolling the scrollview in vertical direction is enables.
    // The default value is true
    public var allowVerticalScrolling = true
    
    // Determines whether auto-scrolling the scrollview in horizontal direction is enables.
    // The defaul value is true
    public var allowHorizontalScrolling = true
    
    public var allowTopBorderDragging = true
    
    public var allowBottomBorderDragging = true
    
    public var allowLeftBorderDragging = true
    
    public var allowRightBorderDragging = true
    
    // The autoScrollInsets defines how close tot he scrollview's edge auto-scrolling will be started.
    // The default values are {44, 44, 44, 44}, the standard toolbar height
    public var autoScrollInsets: UIEdgeInsets = UIEdgeInsets(top: 44, left: 44, bottom: 44, right: 44)
    
    private var translationInWindow: CGPoint?
    
    private var amountScrolled: CGPoint = CGPoint.zero
    
    private var scrollSpeed: CGPoint = CGPoint.zero
    
    private var startLocation: CGPoint?
    
    private var startContentOffset: CGPoint?
    
    private var holding: Bool = false
    
    private var scrolling: Bool = false
    
    private var holdTimer: Timer?
    
    private var displayLink: CADisplayLink?
    
    private var nextDeltaTimeZero: Bool = false
    
    private var previousTimestamp: CFTimeInterval?
    
    private var types: PSYBorderType = .none
    private var matches: [PSYBorderType] = [PSYBorderType]()
    private var originalFrame: CGRect?

    override init(target: Any?, action: Selector?) {
        
        super.init(target: target, action: action)
        allowHorizontalScrolling    = true
        allowVerticalScrolling      = true
        allowTopBorderDragging      = true
        allowBottomBorderDragging   = true
        allowLeftBorderDragging     = true
        allowRightBorderDragging    = true
        minimumPressDuration        = 0.5
        minimumMovement             = 0
        maximumMovement             = 10
        autoScrollInsets = UIEdgeInsets(top: 44, left: 44, bottom: 44, right: 44)
    }
    // The transaltion of the drag gesture in the coordinated system fo the specifired view. Similar to UIPanGestureRecognizer's method.
    public func translationInView(view: UIView) -> CGPoint {
        
        guard let translateInWindow = translationInWindow else {
            return CGPoint(x: 0, y: 0)
        }
        let totalTranslationInWindow = CGPoint(x: translateInWindow.x + amountScrolled.x,
                                               y: translateInWindow.y + amountScrolled.y)
        var totalTranslationInView = view.convert(totalTranslationInWindow, from: nil)
        let totalTranslationOfView = view.convert(CGPoint.zero, from: nil)
        totalTranslationInView = CGPoint(x: totalTranslationInView.x - totalTranslationOfView.x,
                                         y: totalTranslationInView.y - totalTranslationOfView.y)
        return totalTranslationInView
    }
    
    private func enclosingScrollView() -> UIScrollView? {
        
        var view = self.view?.superview
        while (view != nil) {
            if view!.isKind(of: UIScrollView.self) {
                return view as! UIScrollView?
            }
            view = view!.superview
        }
        return nil
    }
    
    @objc private func holdTimerFired(timer: Timer) {
        
        //        holding = false
    }
    
    private func canBeginGesture() -> Bool {
        
        guard let translateInWindow = translationInWindow else {
            return false
        }
        let distance = sqrt(translateInWindow.x * translateInWindow.x + translateInWindow.y * translateInWindow.y)
        return distance >= self.minimumMovement && state == UIGestureRecognizerState.possible
    }
    
    // MARK: Resetting
    
    func tearDown() {
        
        endScrolling()
//        if holdTimer == nil {
//            return
//        }
//        holdTimer!.invalidate()
//        holdTimer = nil
    }
    
    func gestureRecognizerReset() {
        
        //        holding = false
        scrolling = false
        translationInWindow = .zero
        amountScrolled = .zero
        scrollSpeed = .zero
    }
    
    // MARK: AutoScrolling
    
    func beginScrolling() {
        
        if !scrolling {
            scrolling = true
            nextDeltaTimeZero = true
            previousTimestamp = 0.0
            if displayLink == nil {
                displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdate))
                displayLink!.add(to: .main, forMode: .commonModes)
            }
        }
    }
    
    func endScrolling() {
        
        if scrolling {
            scrollSpeed = CGPoint.zero
            scrolling = false
            if displayLink == nil {
                return
            }
            displayLink!.remove(from: .main, forMode: .commonModes)
            displayLink!.invalidate()
            displayLink = nil
        }
    }
    
    func displayLinkUpdate(sender: CADisplayLink) {
        
        if displayLink == nil {
            return
        }
        let currentTime = displayLink!.timestamp
        var deltaTime: CFTimeInterval
        if nextDeltaTimeZero {
            nextDeltaTimeZero = false
            deltaTime = 0
        }
        else {
            deltaTime = currentTime - previousTimestamp!
        }
        previousTimestamp = currentTime
        self.updateWithDelta(deltaTime: deltaTime)
    }
    
    func updateWithDelta(deltaTime: CFTimeInterval) {
        
        guard let startConOffset = startContentOffset else {
            return
        }
        let contentSize = scrollView.contentSize
        let bounds = scrollView.bounds
        let contentInset = scrollView.contentInset
        let maximumContentOffset = CGPoint(x: contentSize.width - bounds.size.width + contentInset.right,
                                           y: contentSize.height - bounds.size.height + contentInset.bottom)
        let minimumContentOffset = CGPoint(x: -contentInset.left,
                                           y: -contentInset.top)
        let maximumAmountScrolled = CGPoint(x: maximumContentOffset.x - startConOffset.x,
                                            y: maximumContentOffset.y - startConOffset.y)
        let minimumAmountScrolled = CGPoint(x: minimumContentOffset.x - startConOffset.x,
                                            y: minimumContentOffset.y - startConOffset.y)
        amountScrolled  = CGPoint(x: amountScrolled.x + scrollSpeed.x * CGFloat(deltaTime),
                                  y: amountScrolled.y + scrollSpeed.y * CGFloat(deltaTime))
        amountScrolled = CGPoint(x: max(minimumAmountScrolled.x, min(maximumAmountScrolled.x, amountScrolled.x)),
                                 y: max(minimumAmountScrolled.y, min(maximumAmountScrolled.y, amountScrolled.y)))
        let offsetX = startConOffset.x + amountScrolled.x
        let offsetY = startConOffset.y + amountScrolled.y
        let offset = CGPoint(x: offsetX,
                             y: offsetY)
        if !scrollView.contentOffset.equalTo(offset) {
            scrollView.contentOffset = offset
            state = .changed
        }
    }
    
    // MARK: Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        guard let count = event.touches(for: self)?.count , count == 1 else {
            self.state = .failed
            return
        }
        guard let touch = touches.first else {
            self.state = .failed
            return
        }
        let location = touch.location(in: view)
        if !frame.contains(location) {
            ignore(touch, for: event)
            return
        }
        startLocation = touch.location(in: nil)
        startContentOffset = scrollView.contentOffset
        if canBeginGesture() {
            self.state = .began
        }
        // Collecting Matching Border dragging.
        types = .none
        matches = [PSYBorderType]()
        
        let point = touch.location(in: scrollView)
        
        guard let targetView = view else {
            return
        }
        let targetFrame = targetView.frame
        if (point.x >= (targetFrame.origin.x - kTolerence) &&
            point.x <= (targetFrame.origin.x + targetFrame.size.width + kTolerence )) {
            if (point.y >= (targetFrame.origin.y - kTolerence) &&
                point.y <= (targetFrame.origin.y + kTolerence)){
                if allowTopBorderDragging {
                    types = .top
                    originalFrame = targetFrame
                }
            }
            else if (point.y >= (targetFrame.origin.y + targetFrame.size.height - kTolerence) &&
                point.y <= (targetFrame.origin.y + targetFrame.size.height + kTolerence)) {
                if allowBottomBorderDragging {
                    types = .bottom
                    originalFrame = targetFrame
                }
            }
        }
        if (point.y >= (targetFrame.origin.y - kTolerence) &&
            point.y <= (targetFrame.origin.y + targetFrame.size.height + kTolerence)) {
            if (point.x >= (targetFrame.origin.x - kTolerence) &&
                point.x <= (targetFrame.origin.x + kTolerence)) {
                if allowLeftBorderDragging {
                    types = .left
                    originalFrame = targetFrame
                }
            }
            else if (point.x >= (targetFrame.origin.x + targetFrame.size.width - kTolerence) &&
                point.x <= (targetFrame.origin.x + targetFrame.size.width + kTolerence)) {
                if allowRightBorderDragging {
                    types = .right
                    originalFrame = targetFrame
                }
            }
        }
        matches.append(types)
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        
        guard let touch = touches.first else {
            self.state = .failed
            return
        }
        let location = touch.location(in: nil)
        guard let start = startLocation else {
            self.state = .failed
            return
        }
        let translation = CGPoint(x: location.x - start.x,
                                  y: location.y - start.y)
        translationInWindow = translation
//        if self.state == .possible {
//            if canBeginGesture() {
//                self.state = .began
//            }
//        }
//        else {
            let contentInset = scrollView.contentInset
            let frame = scrollView.frame
            let locationInSuper = touch.location(in: scrollView.superview)
            var insideRect = UIEdgeInsetsInsetRect(frame, contentInset)
            insideRect = UIEdgeInsetsInsetRect(insideRect, autoScrollInsets)
            var isInside = insideRect.contains(locationInSuper)

            if locationInSuper.y < 0 || locationInSuper.y > (scrollView.superview?.frame.height)! {
                isInside = true
            }
            if isInside {
                self.endScrolling()
                self.state = .changed
            }
            else {
                var speedX: CGFloat = 0
                var speedY: CGFloat = 0
                if allowVerticalScrolling {
                    let minY = min(0, locationInSuper.y - (frame.origin.y + contentInset.top + autoScrollInsets.top))
                    let maxY = max(0, locationInSuper.y - (frame.origin.y + frame.size.height - contentInset.bottom - autoScrollInsets.bottom))
                    speedY = CGFloat(minY) + CGFloat(maxY)
                }
                if allowHorizontalScrolling {
                    let minX = min(0, locationInSuper.x - (frame.origin.x + contentInset.left + autoScrollInsets.left))
                    let maxX = max(0, locationInSuper.x - (frame.origin.x + frame.size.width - contentInset.right - autoScrollInsets.right))
                    speedX = CGFloat(minX) + CGFloat(maxX)
                }
                scrollSpeed = CGPoint(x: speedX * kSpeedMultiplier * kSecond , y: speedY * kSpeedMultiplier * kSecond)
                beginScrolling()
            }
            guard let types = matches.first else {
                return
            }
            guard let currentView = view else {
                return
            }
            guard var newFrame = originalFrame else {
                return
            }
            let translationInSuper = CGPoint(x: locationInSuper.x - start.x, y: locationInSuper.y - start.y)
            switch types {
            case .none:
                break
            case .right:
                newFrame.size.width += translationInSuper.x
                currentView.frame = newFrame
                state = .changed
            case .left:
                newFrame.origin.x += translationInSuper.x
                newFrame.size.width -= translationInSuper.x
                currentView.frame = newFrame
                state = .changed

            case .top:
                newFrame.origin.y += translationInSuper.y
                newFrame.size.height -= translationInSuper.y
                currentView.frame = newFrame
                state = .changed

                break
            case .bottom:
                newFrame.size.height += translationInSuper.y
                currentView.frame = newFrame
                state = .changed
                break
            }
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        
        tearDown()
        if state == .began || state == .changed {
            state = .ended
        }
        else {
            state = .failed
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        
        tearDown()
        if state == .began || state == .changed {
            state = .cancelled
        }
        else {
            state = .failed
        }
    }
    
    override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer == scrollView.pinchGestureRecognizer {
            return true
        }
        if otherGestureRecognizer == scrollView.panGestureRecognizer {
            return true
        }
        return false
    }
    
}
