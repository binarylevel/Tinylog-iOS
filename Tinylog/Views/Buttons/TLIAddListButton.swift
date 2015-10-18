//
//  TLIAddListButton.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIAddListButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.setBackgroundImage(UIImage(named: "add-list"), forState: UIControlState.Normal)
        self.setBackgroundImage(UIImage(named: "add-list"), forState: UIControlState.Highlighted)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let area:CGRect = CGRectInset(self.bounds, -20, -20)
        return CGRectContainsPoint(area, point)
    }
}
