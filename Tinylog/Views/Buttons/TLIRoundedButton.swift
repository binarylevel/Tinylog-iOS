//
//  TLIRoundedButton.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIRoundedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.contentEdgeInsets = UIEdgeInsetsMake(10.0, 20.0, 10.0, 20.0)
        self.titleLabel?.font = UIFont.mediumFontWithSize(17.0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let area:CGRect = CGRectInset(self.bounds, -20, -20)
        return CGRectContainsPoint(area, point)
    }
}
