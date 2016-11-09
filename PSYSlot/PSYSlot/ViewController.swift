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
    private var originalFrame: CGRect = CGRect.zero
    var tapGesture: UITapGestureRecognizer!
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
        collectionView.setNeedsDisplay()
        let scrollViewSize = CGSize(width: collectionView.contentSize.width, height: collectionView.contentSize.height - 24)
        let rect = CGRect(origin: CGPoint(x: 0, y: 24), size: scrollViewSize)
        contentView = UIView(frame: rect)
        contentView.backgroundColor = UIColor.clear
        contentView.setNeedsDisplay()
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
    
    func handleTap(gesture: UITapGestureRecognizer) {
        
        let locationInCollectionView = gesture.location(in: collectionView)
        guard let controlView = controlSlots.first else {
            return
        }
        var begin = round(locationInCollectionView.x/cellWidth)
        let endIndex = Int(begin + controlView.slot)
        if endIndex > slots.count - 2 {
            begin = CGFloat(slots.count - 1) - CGFloat(controlView.slot)
        }
        var newFrame = controlView.frame
        var newXOrigin = CGFloat(begin) * cellWidth
        let cagingArea = self.contentView.frame
        let cagingAreaOriginX = cagingArea.minX
        let cagingAreaRightSide = cagingAreaOriginX + cagingArea.width
        if newXOrigin <= cagingAreaOriginX  {
            newXOrigin = 0
        }
        if (newXOrigin + newFrame.width) >= cagingAreaRightSide {
            newXOrigin = cagingArea.width - newFrame.size.width
        }
        newFrame.origin.x = newXOrigin
        controlView.frame = newFrame
        controlView.setNeedsDisplay()
        setControlAvailability()
        controlSnap(view: controlView)
    }

    func enableTap() {
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tapGesture)
    }

    func removeTap() {
        if (collectionView != nil && tapGesture != nil) {
            collectionView.removeGestureRecognizer(tapGesture)
        }
    }
    
    func handleDeviceOrientationDidChangeNotification(notification: NSNotification) {
        
        collectionView.reloadData()
        removeTap()
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
        slots = slots.sorted {
            return $0.begin! < $1.begin!
        }
        collectionView.reloadData()
        removeTap()
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
            let begin: Int? = slots.index{ $0.begin == startTime }
            let end: Int? = slots.index{ $0.begin == endTime }
            if end != nil && begin != nil {
                let slotView = SlotControlView(begin: CGFloat(begin!), slot: CGFloat(end!) - CGFloat(begin!), width: width, height: contentView.frame.size.height - 1, type: .control)
                slotView.enableLeft(seperator: true, handle: true)
                slotView.enableRight(seperator: true, handle: true)
                let psyGestureRecognizeer = PSYSlotGestureRecognizer(target: self, action: #selector(dragRecognized))
                psyGestureRecognizeer.allowHorizontalScrolling = allowHorizontalScrolling
                psyGestureRecognizeer.allowVerticalScrolling = allowVerticalScrolling
                psyGestureRecognizeer.allowTopBorderDragging = false
                psyGestureRecognizeer.allowBottomBorderDragging = false
                slotView.addGestureRecognizer(psyGestureRecognizeer)
                enableTap()
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
        setControlAvailability()
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
                    let slotView = SlotView(begin: CGFloat(begin), slot: 1, width: width, height: contentView.frame.size.height - 1, type: .past)
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
            let begin: Int? = slots.index{ $0.begin == startTime }
            let end: Int? = slots.index{ $0.begin == endTime }
            if end != nil && begin != nil {
                let slotView = SlotView(begin: CGFloat(begin!), slot: CGFloat(end!) - CGFloat(begin!), width: width, height: contentView.frame.size.height - 1, type: .taken)
                slotView.clipsToBounds = true
                views.append(slotView)
            }
        }
        for subviews in contentView.subviews {
            if subviews.tag == SlotViewType.taken.rawValue {
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
            originalFrame = view.frame
            view.superview?.bringSubview(toFront: view)
            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform.identity
                view.alpha = 0.7
            })
            setControlAvailability()
        }
        else if (recognizer.state == UIGestureRecognizerState.changed) {
            
            let translation = recognizer.translationInView(view: contentView)
            let center = CGPoint(x:startCenter.x + ((allowHorizontalScrolling) ? translation.x : 0),
                                 y:startCenter.y + ((allowVerticalScrolling) ? translation.y : 0))
            guard let types = recognizer.matches.first else {
                return
            }
            var newFrame = originalFrame
            switch types {
            case .none:
                view.center = center
                break
            case .right:
                newFrame.size.width += translation.x
                view.frame = newFrame
            case .left:
                newFrame.origin.x += translation.x
                newFrame.size.width -= translation.x
                view.frame = newFrame
            case .top:
                newFrame.origin.y += translation.y
                newFrame.size.height -= translation.y
                view.frame = newFrame
                break
            case .bottom:
                newFrame.size.height += translation.y
                view.frame = newFrame
                break
            }
            view.setNeedsDisplay()
            setControlAvailability()
        }
        else if (recognizer.state == UIGestureRecognizerState.ended || recognizer.state == UIGestureRecognizerState.cancelled) {
            setControlAvailability()
            controlSnap(view: view as! SlotView)
        }
        else if (recognizer.state == UIGestureRecognizerState.failed) {
            setControlAvailability()
            controlSnap(view: view as! SlotView)
        }
    }
    
    func controlSnap(view: SlotView) {
        
        view.begin = round(view.frame.minX/cellWidth)
        view.slot = round(view.frame.width/cellWidth)
        if view.slot <= 0 {
            view.slot = 1
        }
        if view.begin < 0 {
            view.begin = 0
        }
        let newFrame = view.frame
        var newXOrigin = CGFloat(view.begin) * cellWidth
        let cagingArea = contentView.frame
        let cagingAreaOriginX = cagingArea.minX
        let cagingAreaRightSide = cagingAreaOriginX + cagingArea.width
        if (newXOrigin + newFrame.width) >= cagingAreaRightSide {
            newXOrigin = cagingArea.width - newFrame.size.width
            view.begin = round(newXOrigin/cellWidth) - 1
        }
        if newXOrigin <= cagingAreaOriginX  {
            view.begin = 0
        }
        
        UIView.animate(withDuration: 0.2) {
            view.transform = CGAffineTransform.identity
            view.alpha = 1.0
            view.frame = CGRect(x: CGFloat(view.begin) * self.cellWidth,
                                y: 0,
                                width: CGFloat(view.slot) * self.cellWidth,
                                height: self.contentView.frame.size.height)
            view.setNeedsDisplay()
        }
    }
    
    func setControlAvailability() {
        
        guard let controlView = controlSlots.first else {
            return
        }
        if self.checkInterceptView() {
            controlView.setType(type: .unavailable)
        }
        else {
            controlView.setType(type: .control)
        }
    }
    
    func checkInterceptView() -> Bool {
        
        guard let controlView = controlSlots.first else {
            return true
        }
        var newFrame = controlView.frame
        newFrame.origin.x = newFrame.origin.x + 5
        newFrame.size.width = newFrame.size.width - 5
        return (takenSlots.filter{ $0.frame.intersects(newFrame) }.count > 0 || pastSlots.filter{ $0.frame.intersects(newFrame) }.count > 0 ) ? true : false
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

