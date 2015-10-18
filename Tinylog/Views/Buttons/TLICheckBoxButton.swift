//
//  TLICheckBoxButton.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLICheckBoxButton: UIButton {
    
    var tableViewCell:UITableViewCell?
    var circleView:TLITouchableView?
    var checkMarkIcon:UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        circleView = TLITouchableView(frame: CGRectMake(0.0, 0.0, 30.0, 30.0))
        circleView?.layer.cornerRadius = 30.0 / 2
        circleView?.layer.borderColor = UIColor.tinylogMainColor().CGColor
        circleView?.layer.borderWidth = 1.0
        circleView?.layer.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0).CGColor
        circleView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.addSubview(circleView!)
        
        checkMarkIcon = UIImageView(image: UIImage(named: "check"))
        checkMarkIcon?.frame = CGRectMake(30.0 / 2 - 16.0 / 2.0, 30.0 / 2.0 - 12.0 / 2.0, 16.0, 12.0)
        self.addSubview(checkMarkIcon!)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let area:CGRect = CGRectInset(self.bounds, -20, -20)
        return CGRectContainsPoint(area, point)
    }
    
}
