//
//  ViewController.swift
//  PSYSlot
//
//  Created by Shiuh Yaw Phang on 07/11/2016.
//  Copyright © 2016 Shiuh Yaw Phang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var startCenter: CGPoint = CGPoint.zero
    var contentView: UIView!
    var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let scrollViewHeight = 1000
        let scrollViewWidth = 1000
        let scrollViewSize = CGSize(width: scrollViewWidth, height: scrollViewHeight)
        let rect = CGRect(origin: CGPoint.zero, size: scrollViewSize)
        let labelFrame = CGRect(x: 0, y: 0, width: 284, height: 62)

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.blue
        scrollView.contentSize = scrollViewSize
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        var indicatorInsets = scrollView.scrollIndicatorInsets
        indicatorInsets.bottom = scrollView.contentInset.bottom
        scrollView.scrollIndicatorInsets = indicatorInsets
        view.insertSubview(scrollView, at: 0)
        
        contentView = UIView(frame: rect)
        contentView.backgroundColor = UIColor.red
        scrollView.addSubview(contentView)
        
        let text = "Tap & hold a colored view to start dragging it. " + "Move it to the edge of the scroll view to start auto-scrolling."
        let label = UILabel(frame: labelFrame)
        label.numberOfLines = 0
        label.text = text
        label.textAlignment = NSTextAlignment.center
        label.center = CGPoint(x: scrollViewWidth/2, y: scrollViewHeight/2)
        contentView.addSubview(label)

        scrollView.contentOffset = CGPoint(x: label.center.x - scrollView.bounds.size.width / 2 ,
                                           y: label.center.y - scrollView.bounds.size.height / 2)
        let count = 1
        for _ in 0..<count {
            srandom(314159265)
            var randomRect = CGRect.zero
            var canPlace = false
            while !canPlace {
                let randomPoint = CGPoint(x: 100 + Int(arc4random_uniform(3)) % (scrollViewWidth - 200),
                                          y: 100 + Int(arc4random_uniform(3)) % (scrollViewHeight - 200))
                randomRect = CGRect(origin: randomPoint, size: CGSize(width: 100, height: 100))
                canPlace = true
                for subview in contentView.subviews {
                    if randomRect.intersects(subview.frame) {
                        canPlace = false
                        break
                    }
                }
            }
            
            let view = UIView(frame: randomRect)
            let hue = CGFloat((Int(arc4random_uniform(3)) % 256 / 256))
            let saturation = CGFloat((Int(arc4random_uniform(3)) % 128 / 256)) + 0.5
            let brightness = CGFloat((Int(arc4random_uniform(3)) % 128 / 256)) + 0.5
            let randomColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
            view.backgroundColor = randomColor
            contentView.addSubview(view)
            let holdDragRecognizer = PSYSlotGestureRecognizer(target: self, action: #selector(dragRecognized))
            holdDragRecognizer.delegate = self
            view.addGestureRecognizer(holdDragRecognizer)
        }
    }

    func dragRecognized(recognizer: PSYSlotGestureRecognizer) {
        
        guard let view = recognizer.view else {
            return
        }
        if recognizer.state == UIGestureRecognizerState.began {
            startCenter = view.center
            view.superview?.bringSubview(toFront: view)
            UIView.animate(withDuration: 0.2, animations: { 
                view.transform = CGAffineTransform.identity
                view.alpha = 0.7
            })
        }
        else if (recognizer.state == UIGestureRecognizerState.changed) {
            let translation = recognizer.translationInView(view: contentView)
            let center = CGPoint(x: startCenter.x + translation.x,
                                 y: startCenter.y + translation.y)
            view.center = center
        }
        else if (recognizer.state == UIGestureRecognizerState.ended || recognizer.state == UIGestureRecognizerState.cancelled) {
            UIView.animate(withDuration: 0.2, animations: { 
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0
            })
        }
        else if (recognizer.state == UIGestureRecognizerState.failed) {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return contentView
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    
    // if your subviews are scrollviews, might need to tell the gesture recognizer
    // to allow simultaneous gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

