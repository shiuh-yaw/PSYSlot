//
//  DateExtension.swift
//  PSYSlot
//
//  Created by Shiuh Yaw Phang on 07/11/2016.
//  Copyright © 2016 Shiuh Yaw Phang. All rights reserved.
//

import Foundation


extension Date {
    
    static public func < (first: Date, second: Date) -> Bool {
        return first.compare(second as Date) == .orderedAscending
    }
    
    static public func > (first: Date, second: Date) -> Bool {
        return first.compare(second) == .orderedDescending
    }
    
    static public func <= (first: Date, second: Date) -> Bool {
        let cmp = first.compare(second)
        return cmp == .orderedAscending || cmp == .orderedSame
    }
    
    static public func >= (first: Date, second: Date) -> Bool {
        let cmp = first.compare(second)
        return cmp == .orderedDescending || cmp == .orderedSame
    }
    
    static public func == (first: Date, second: Date) -> Bool {
        return first.compare(second) == .orderedSame
    }

    var shortDate: String {
        let shortDate = DateFormatter()
        shortDate.dateStyle = .medium
        return shortDate.string(from: self)
    }
    
    var shortTime: String {
        let shortTime = DateFormatter()
        shortTime.dateFormat = "h:mm a"
        return shortTime.string(from:self)
    }
    
    var extremeShortTime: String {
        let extremeShortTime = DateFormatter()
        extremeShortTime.dateFormat = "h a"
        return extremeShortTime.string(from:self)
    }
}
