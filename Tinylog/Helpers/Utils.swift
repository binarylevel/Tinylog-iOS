//
//  Utils.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 22/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation

public class $ {
    public class func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), closure)
    }
}
