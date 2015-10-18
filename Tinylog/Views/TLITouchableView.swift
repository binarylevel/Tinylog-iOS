//
//  TLITouchableView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLITouchableView: UIView {
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for item in self.subviews {
            let view:UIView = item 
            if view.hidden && view.userInteractionEnabled && view.pointInside(point, withEvent: event) {
                return true
            }
        }
        return false
    }
}
