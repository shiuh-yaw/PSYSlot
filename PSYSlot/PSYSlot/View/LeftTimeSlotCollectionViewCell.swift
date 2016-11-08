//
//  LeftTimeSlotCollectionViewCell.swift
//  Space
//
//  Created by Shiuh Yaw Phang on 29/09/2016.
//  Copyright © 2016 Shiuh Yaw Phang. All rights reserved.
//

import UIKit

class LeftTimeSlotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var leftSeparatorView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        timeLabel.sizeToFit()
    }
}
