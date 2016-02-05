//
//  UIColor+TinylogiOSAdditions.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(rgba: String) {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index = rgba.startIndex.advancedBy(1)
            let hex = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                if hex.characters.count == 6 {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if hex.characters.count == 8 {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid rgb string, length should be 7 or 9")
                }
            } else {
                print("scan hex error")
            }
        } else {
            print("invalid rgb string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    class func tinylogNavigationBarColor() -> UIColor {
        return UIColor(hue: 0.0, saturation: 0.0, brightness: 0.98, alpha: 1.00)
    }
    
    class func tinylogBackgroundColor() -> UIColor {
        return UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }
    
    class func tinylogTableViewLineColor() -> UIColor {
        return UIColor(red: 224.0 / 255.0, green: 224.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
    }
    
    class func tinylogTextColor() -> UIColor {
        return UIColor(red: 77.0 / 255.0, green: 77.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
    }
    
    class func tinylogItemColor() -> UIColor {
        return UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }
    
    class func tinylogMainColor() -> UIColor {
        return UIColor(red: 43.0 / 255.0, green: 174.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
    }
    
    class func tinylogNumbersColor() -> UIColor {
        return UIColor(red:76.0 / 255.0, green:90.0 / 255.0, blue:100.0 / 255.0 ,alpha:1.0)
    }
    
    class func tinylogNavigationBarLineColor()->UIColor {
        return UIColor(red: 205.0 / 255.0, green: 205.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
    }
    
    class func tinylogNavigationBarDarkColor()->UIColor {
        return UIColor(red: 20.0 / 255.0, green: 21.0 / 255.0, blue: 24.0 / 255.0, alpha: 1.0)
    }
    
    class func tinylogNavigationBarDayColor()->UIColor {
        return UIColor(red: 243.0 / 255.0, green: 243.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)
    }
}

