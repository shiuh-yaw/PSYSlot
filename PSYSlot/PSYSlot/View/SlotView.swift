//
//  SlotView.swift
//  PSYSlot
//
//  Created by Shiuh Yaw Phang on 08/11/2016.
//  Copyright © 2016 Shiuh Yaw Phang. All rights reserved.
//

import UIKit

enum SlotViewType: Int {
    case taken
    case unavailable
    case available
    case past
    case control
}

class SlotView: UIView {

    var begin: CGFloat = 0.0
    var slot: CGFloat = 0.0
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }

    init(begin: CGFloat, slot: CGFloat, width: CGFloat, height: CGFloat, type: SlotViewType) {
        
        self.begin = begin
        self.slot = slot
        let x = CGFloat(begin * width)
        let width = CGFloat(slot * width)
        let frame = CGRect(x: x + 1, y: 0.0, width: width - 1, height: height)
        super.init(frame: frame)
        setType(type: type)
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
    }
    
    func setType(type:SlotViewType) {
        
        switch type {
        case .taken:
            let tileImage: UIImage = UIImage(named: "slash")!
            let bgColor = UIColor(patternImage: tileImage)
            backgroundColor = bgColor
            tag = type.rawValue
        case .unavailable:
            let bgColor = UIColor(red: 225.0 / 255.0, green: 82.0 / 255.0, blue: 61.0 / 255.0, alpha: 1.0)
            self.backgroundColor = bgColor.withAlphaComponent(0.7)
            tag = type.rawValue
        case .available:
            let bgColor = UIColor.clear
            self.backgroundColor = bgColor
            tag = type.rawValue
        case .past:
            let bgColor = UIColor(red: 249.0 / 255.0, green: 250.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
            self.backgroundColor = bgColor
            tag = type.rawValue
        case .control:
            let bgColor = UIColor(red: 62.0 / 255.0, green: 178.0 / 255.0, blue: 142.0 / 255.0, alpha: 1.0)
            self.backgroundColor = bgColor.withAlphaComponent(0.7)
            tag = type.rawValue
        }
    }
    
}
