//
//  SlotControlView.swift
//  PSYSlot
//
//  Created by Shiuh Yaw Phang on 09/11/2016.
//  Copyright © 2016 Shiuh Yaw Phang. All rights reserved.
//

import UIKit

class SlotControlView: SlotView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var leftSeparator: UIView?
    var leftHanlder: UIView?
    var isLeftHandled = false
    var rightSeparator: UIView?
    var rightHanlder: UIView?
    var isRightHandled = false
    var topSeparator: UIView?
    var topHanlder: UIView?
    var isTopHandled = false
    var bottomSeparator: UIView?
    var bottomHanlder: UIView?
    var isBottomHandled = false
    let handlerSize = CGSize(width: 20, height: 20)
    let separatorWidth: CGFloat = 2

    override init(begin: CGFloat, slot: CGFloat, width: CGFloat, height: CGFloat, type: SlotViewType) {
        
        let x = CGFloat(begin * width)
        let width = CGFloat(slot * width)
        let frame = CGRect(x: x + 1, y: 0.0, width: width - 1, height: height)
        super.init(frame: frame)
        self.begin = begin
        self.slot = slot
        setType(type: type)
    }
    
    deinit {
        
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        if leftSeparator != nil {
            leftSeparator!.backgroundColor = backgroundColor
        }
        if leftHanlder != nil {
            var newFrame = rect
            newFrame.origin.x = -handlerSize.width/2
            newFrame.origin.y = rect.height/2 - handlerSize.height/2
            newFrame.size = handlerSize
            leftHanlder!.layer.borderColor = backgroundColor?.cgColor
            leftHanlder!.layer.borderWidth = 2
            leftHanlder!.frame = newFrame
            leftHanlder!.backgroundColor = UIColor.white
        }
        if rightSeparator != nil {
            var newFrame = rect
            newFrame.origin.x = rect.size.width - separatorWidth  + 1
            newFrame.size.width = separatorWidth
            rightSeparator!.backgroundColor = backgroundColor
            rightSeparator!.frame = newFrame
        }
        if rightHanlder != nil {
            var newFrame = rect
            newFrame.origin.x = rect.size.width - handlerSize.width/2
            newFrame.origin.y = rect.height/2 - handlerSize.height/2
            newFrame.size = handlerSize
            rightHanlder!.layer.borderColor = backgroundColor?.cgColor
            rightHanlder!.layer.borderWidth = 2
            rightHanlder!.frame = newFrame
            rightHanlder!.backgroundColor = UIColor.white
        }
    }
    
    func enableRight(seperator: Bool, handle: Bool) {
        
        isRightHandled = handle
        if seperator {
            rightSeparator = UIView(frame:CGRect(x: frame.width - separatorWidth + 1, y: 0, width: separatorWidth, height: frame.height))
            rightSeparator!.backgroundColor = backgroundColor
            addSubview(rightSeparator!)
        }
        if handle {
            rightHanlder = UIView(frame: CGRect(x: frame.width - (handlerSize.width)/2 - 1, y:  frame.height/2 - handlerSize.height/2 , width: handlerSize.width, height: handlerSize.height))
            rightHanlder!.backgroundColor = UIColor.white
            rightHanlder!.layer.cornerRadius = handlerSize.height/2
            rightHanlder!.clipsToBounds = true
            rightHanlder!.layer.borderColor = backgroundColor?.cgColor
            rightHanlder!.layer.borderWidth = 2
            addSubview(rightHanlder!)
        }
    }
    
    func enableLeft(seperator: Bool, handle: Bool) {
        
        isLeftHandled = handle
        if seperator {
            leftSeparator = UIView(frame:CGRect(x: 0, y: 0, width: separatorWidth, height: frame.height))
            leftSeparator!.backgroundColor = backgroundColor
            addSubview(leftSeparator!)
        }
        if handle {
            leftHanlder = UIView(frame: CGRect(x: -handlerSize.width/2, y: frame.height/2 - handlerSize.height/2, width: handlerSize.width, height: handlerSize.height))
            leftHanlder!.backgroundColor = UIColor.white
            leftHanlder!.layer.cornerRadius = handlerSize.height/2
            leftHanlder!.clipsToBounds = true
            leftHanlder!.layer.borderColor = backgroundColor?.cgColor
            leftHanlder!.layer.borderWidth = 2
            addSubview(leftHanlder!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
