//
//  Schedule.swift
//  PSYSlot
//
//  Created by Shiuh Yaw Phang on 07/11/2016.
//  Copyright © 2016 Shiuh Yaw Phang. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class Schedule: Object {

    dynamic var beginString: String? = nil
    dynamic var endString: String? = nil
    dynamic var begin: Date? = nil
    dynamic var end: Date? = nil
    dynamic var display_begin: String? = nil
    dynamic var display_end: String? = nil
    
    required convenience init?(map: Map) {
        
        self.init()
        mapping(map: map)
        
    }
}

extension Schedule: Mappable {
    
    func mapping(map: Map) {
        beginString <- map["begin"]
        endString <- map["end"]
        begin <- (map["begin"], CustomDateFormatTransform(formatString: "HH:mm"))
        end <- (map["end"], CustomDateFormatTransform(formatString: "HH:mm"))
        display_begin <- map["display_begin"]
        display_end <- map["display_end"]
    }
    
}

