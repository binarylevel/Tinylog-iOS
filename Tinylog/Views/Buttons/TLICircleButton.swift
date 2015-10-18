//
//  TLICircleButton.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLICircleButton: UIButton {
    
    var borderColor:UIColor?
    var borderSize:CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMaskToBounds(self.bounds)
    }
    
    func updateMaskToBounds(maskBounds:CGRect) {
        let maskLayer:CAShapeLayer = CAShapeLayer()
        let maskPath:CGPathRef = CGPathCreateWithEllipseInRect(maskBounds, nil)
        maskLayer.bounds = maskBounds
        maskLayer.path = maskPath
        maskLayer.fillColor = UIColor.blackColor().CGColor
        let point:CGPoint = CGPointMake(maskBounds.size.width / 2, maskBounds.size.height / 2)
        maskLayer.position = point
        self.layer.mask = maskLayer
        self.layer.cornerRadius = CGRectGetHeight(maskBounds) / 2.0
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
}
