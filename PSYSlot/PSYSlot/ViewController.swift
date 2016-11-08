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
    let cellWidth:CGFloat = 65
    var slots:[Schedule] = [Schedule]()
    var pastSlots:[SlotView] = [SlotView]()
    var takenSlots:[SlotView] = [SlotView]()
    var controlSlots:[SlotView] = [SlotView]()
    let allowHorizontalScrolling = true
    let allowVerticalScrolling = false

    private var startCenter: CGPoint = CGPoint.zero
    var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.register(UINib(nibName: rightTimeSlotCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: rightTimeSlotCollectionViewCell)
        collectionView!.register(UINib(nibName: leftTimeSlotCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: leftTimeSlotCollectionViewCell)
    }
    
    func setupContentView() {
        
        if contentView != nil {
            contentView.removeFromSuperview()
        }
        let scrollViewSize = CGSize(width: collectionView.contentSize.width, height: collectionView.contentSize.height)
        let rect = CGRect(origin: CGPoint(x: 0, y: 24), size: scrollViewSize)
        contentView = UIView(frame: rect)
        contentView.backgroundColor = UIColor.clear
        collectionView.addSubview(contentView)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        addRotationObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        updateTimeSlots()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        removeRotationObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
    }
    
    func addRotationObserver() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDeviceOrientationDidChangeNotification),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    func removeRotationObserver() {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleDeviceOrientationDidChangeNotification(notification: NSNotification) {
        
        collectionView.reloadData()
        setupContentView()
        updateTakenViews(width: cellWidth)
        updatePastSlot(width: cellWidth)
        updateControlSlot(width: cellWidth)
    }

    func updateTimeSlots() {
        
        if slots.count > 0 {
            slots.removeAll()
        }
        let beginOfToday = Date().setTimeOfDate(0, minute: 0, second: 0)
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
        collectionView.reloadData()
        setupContentView()
        updateTakenViews(width: cellWidth)
        updatePastSlot(width: cellWidth)
        updateControlSlot(width: cellWidth)
    }
    
    func updateControlSlot(width: CGFloat) {
        
        let schedule = Schedule()
        schedule.begin = Date().setTimeOfDate(13, minute: 30, second: 0)
        schedule.end = Date().setTimeOfDate(14, minute: 0, second: 0)
        schedule.display_begin = schedule.begin?.shortTime
        schedule.display_end = schedule.end?.shortTime
        schedule.beginString = schedule.begin?.toString(.custom("HH:mm"))
        schedule.endString = schedule.end?.toString(.custom("HH:mm"))
        var views = [SlotView]()
        var events = [Schedule]()
        events.append(schedule)
        
        for event in events {
            guard let startTime = event.begin , let endTime = event.end else {
                return
            }
            var begin: Int?
            var end: Int?
            for schedule in slots {
                guard let scheduleBegin = schedule.begin  else {
                    return
                }
                if startTime.shortTime == scheduleBegin.shortTime {
                    begin = slots.index(of:schedule)
                }
                else if endTime.shortTime == scheduleBegin.shortTime {
                    end = slots.index(of:schedule)
                }
            }
            if end != nil && begin != nil {
                let slotView = SlotView(begin: CGFloat(begin!), slot: CGFloat(end!) - CGFloat(begin!), width: width, height: contentView.frame.size.height, type: .control)
                let psyGestureRecognizeer = PSYSlotGestureRecognizer(target: self, action: #selector(dragRecognized))
                psyGestureRecognizeer.allowHorizontalScrolling = allowHorizontalScrolling
                psyGestureRecognizeer.allowVerticalScrolling = allowVerticalScrolling
                psyGestureRecognizeer.allowTopBorderDragging = false
                psyGestureRecognizeer.allowBottomBorderDragging = false
                slotView.addGestureRecognizer(psyGestureRecognizeer)
                slotView.clipsToBounds = true
                views.append(slotView)
            }
        }
        for subviews in contentView.subviews {
            if subviews.tag == SlotViewType.control.rawValue {
                subviews.removeFromSuperview()
            }
        }
        for view in views {
            contentView.addSubview(view as UIView)
        }
        controlSlots = views.map({(view) in
            return view
        })
    }
    
    func updatePastSlot(width:CGFloat) {
        
        let today = Date()
        var views = [SlotView]()
        for schedule in slots {
            var isPast = false
            let scheduleDate = Date().setTimeOfDate(schedule.begin!.hour(), minute: schedule.begin!.minute(), second: schedule.begin!.seconds())
            if scheduleDate.isEarlierThanDate(today) {
                isPast = true
            }
            if scheduleDate.isLaterThanDate(Date().setTimeOfDate(18, minute: 0, second: 0)) {
                isPast = true
            }
            if isPast {
                if let begin = slots.index(of:schedule) {
                    let slotView = SlotView(begin: CGFloat(begin), slot: 1, width: width, height: contentView.frame.size.height, type: .past)
                    for view in takenSlots {
                        if begin >= Int(view.begin) &&  begin < Int(view.begin + view.slot) {
                            slotView.backgroundColor = UIColor.clear
                        }
                    }
                    slotView.clipsToBounds = true
                    views.append(slotView)
                }
            }
        }
        for subviews in contentView.subviews {
            if subviews.tag == SlotViewType.past.rawValue {
                subviews.removeFromSuperview()
            }
        }
        for view in views {
            contentView.addSubview(view as UIView)
        }
        pastSlots = views.map({(view) in
            return view 
        })
    }
    
    func updateTakenViews(width: CGFloat) {
        
        let schedule = Schedule()
        schedule.begin = Date().setTimeOfDate(14, minute: 30, second: 0)
        schedule.end = Date().setTimeOfDate(16, minute: 0, second: 0)
        schedule.display_begin = schedule.begin?.shortTime
        schedule.display_end = schedule.end?.shortTime
        schedule.beginString = schedule.begin?.toString(.custom("HH:mm"))
        schedule.endString = schedule.end?.toString(.custom("HH:mm"))
        
        var views = [SlotView]()
        var events = [Schedule]()
        events.append(schedule)
        
        for event in events {
            guard let startTime = event.begin , let endTime = event.end else {
                return
            }
            var begin: Int?
            var end: Int?
            for schedule in slots {
                guard let scheduleBegin = schedule.begin  else {
                    return
                }
                if startTime.shortTime == scheduleBegin.shortTime {
                    begin = slots.index(of:schedule)
                }
                else if endTime.shortTime == scheduleBegin.shortTime {
                    end = slots.index(of:schedule)
                }
            }
            if end != nil && begin != nil {
                let slotView = SlotView(begin: CGFloat(begin!), slot: CGFloat(end!) - CGFloat(begin!), width: width, height: contentView.frame.size.height, type: .unavailable)
                slotView.clipsToBounds = true
                views.append(slotView)
            }
        }
        for subviews in contentView.subviews {
            if subviews.tag == SlotViewType.unavailable.rawValue {
                subviews.removeFromSuperview()
            }
        }
        for view in views {
            contentView.addSubview(view as UIView)
        }
        takenSlots = views.map({(view) in
            return view
        })
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
            var newXOrigin = view.frame.minX + ((allowHorizontalScrolling) ? translation.x : 0)
            var newYOrigin = view.frame.minY + ((allowVerticalScrolling) ? translation.y : 0)
            let center = CGPoint(x:startCenter.x + ((allowHorizontalScrolling) ? translation.x : 0),
                                 y:startCenter.y + ((allowVerticalScrolling) ? translation.y : 0))
            let cagingAreaOriginX = contentView.frame.minX
            let cagingAreaOriginY = contentView.frame.minY
            let cagingAreaRightSide = cagingAreaOriginX + contentView.frame.width
            let cagingAreaBottomSide = cagingAreaOriginY + contentView.frame.height
            if !contentView.frame.equalTo(CGRect.zero) {
                if newXOrigin <= cagingAreaOriginX || (newXOrigin + view.frame.width) >= cagingAreaRightSide {
                    newXOrigin = view.frame.minX
                }
                if newYOrigin <= cagingAreaOriginY || (newYOrigin + view.frame.height) >= cagingAreaBottomSide {
                    newYOrigin = view.frame.minY
                }
            }
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
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return slots.count
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

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return CGFloat(0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return CGFloat(0)
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

