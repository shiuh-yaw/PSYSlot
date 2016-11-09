//
//  ArrayExtension.swift
//  PSYSlot
//
//  Created by Shiuh Yaw Phang on 09/11/2016.
//  Copyright © 2016 Shiuh Yaw Phang. All rights reserved.
//

import Foundation

extension Array {
    
    func midIndex() -> Index {
        
        return startIndex + (count / 2)
    }
    
    mutating func searchBegin<T: Schedule>(forElement key: T) -> Int? {
        
        var result:Int? = nil
        let min = startIndex
        let max = endIndex - 1
        let mid = midIndex()
        
        if key.begin! > (self[max] as! T).begin! || key.begin! < (self[min] as! T).begin! {
            return nil
        }
        
        let n = self[mid] as! T
        
        if n.begin! > key.begin! {
            var slice = Array(self[min...mid - 1])
            result = slice.searchBegin(forElement: key)
        }
        else if n.begin! < key.begin! {
            var slice = Array(self[mid + 1...max])
            result = slice.searchBegin(forElement: key)
        }
        else {
            result = self.index{ ($0 as! T) == n }
        }
        return result
    }
    
    mutating func searchEnd<T: Schedule>(forElement key: T) -> Int? {
        
        var result:Int? = nil
        let min = startIndex
        let max = endIndex - 1
        let mid = midIndex()
        
        if key.end! > (self[max] as! T).end! || key.end! < (self[min] as! T).end! {
            return nil
        }
        
        let n = self[mid] as! T
        
        if n.end! > key.end! {
            var slice = Array(self[min...mid - 1])
            result = slice.searchBegin(forElement: key)
        }
        else if n.end! < key.end! {
            var slice = Array(self[mid + 1...max])
            result = slice.searchBegin(forElement: key)
        }
        else {
            result = self.index{ ($0 as! T) == n }
        }
        return result
    }

}
