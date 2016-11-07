//
//  ViewController.swift
//  PSYSlot
//
//  Created by Shiuh Yaw Phang on 07/11/2016.
//  Copyright © 2016 Shiuh Yaw Phang. All rights reserved.
//

import UIKit
import AFDateHelper

class ViewController: UIViewController {

    let rightTimeSlotCollectionViewCell = "RightTimeSlotCollectionViewCell"
    let leftTimeSlotCollectionViewCell = "LeftTimeSlotCollectionViewCell"
    @IBOutlet weak var collectionView: UICollectionView!
    var numberOfSlot = 0
    var cellWidth:CGFloat = 0
    var slots:[Schedule] = [Schedule]()
    private var startCenter: CGPoint = CGPoint.zero
    var contentView: UIView!
    var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.register(UINib(nibName: rightTimeSlotCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: rightTimeSlotCollectionViewCell)
        collectionView!.register(UINib(nibName: leftTimeSlotCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: leftTimeSlotCollectionViewCell)
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        updateSlots()
    }
    
    func updateSlots() {
        
        if slots.count > 0 {
            slots.removeAll()
        }
        let beginOfToday = Date().setTimeOfDate(8, minute: 0, second: 0)
        let endOfToday = Date().setTimeOfDate(24, minute: 0, second: 0)
        let duration = Int(round((CGFloat(endOfToday.minutesAfterDate(beginOfToday)) / 30))) + 1
        var beginDateTime: Date = beginOfToday
        var endDateTime: Date
        if duration < 0 {
            return
        }
        for _ in 0..<duration {
            endDateTime = beginDateTime.dateByAddingMinutes(Int(30))
            let schedule = Schedule()
            schedule.begin = beginDateTime
            schedule.end = endDateTime
            schedule.display_begin = beginDateTime.shortTime
            schedule.display_end = endDateTime.shortTime
            schedule.beginString = beginDateTime.toString(.custom("HH:mm"))
            schedule.endString = endDateTime.toString(.custom("HH:mm"))
            slots.append(schedule)
            beginDateTime = endDateTime
        }
        numberOfSlot = self.slots.count
        cellWidth = (UIScreen.main.bounds.size.width/CGFloat(slots.count)) * 2
        collectionView.reloadData()
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

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfSlot
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row % 2 == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:leftTimeSlotCollectionViewCell, for: indexPath) as! LeftTimeSlotCollectionViewCell
            guard let begin = self.slots[indexPath.row].begin else {
                return cell
            }
            let beginShortTime = begin.extremeShortTime
            cell.timeLabel.text = beginShortTime
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:rightTimeSlotCollectionViewCell, for: indexPath) as! RightTimeSlotCollectionViewCell
        cell.rightSeparator.isHidden = true
        if indexPath.row == slots.count - 1 {
            cell.rightSeparator.isHidden = false
        }
        return cell
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

