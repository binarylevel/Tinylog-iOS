//
//  SGBackgroundView.swift
//  SGBackgroundView
//
//  Created by Spiros Gerokostas on 15/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

public class SGBackgroundView: UIView {
    var _width:CGFloat?
    var _height:CGFloat?
    var _color:NSString?
    var _bgColor:UIColor?
    var _topLine:Bool?
    var _xPosLine:CGFloat?
    var _lineColor:UIColor?
    
    public var xPosLine:CGFloat {
        set {
            _xPosLine = newValue
            self.setNeedsDisplay()
        }
        get {
            return _xPosLine!
        }
    }
    
    public var topLine:Bool {
        set {
            _topLine = newValue
            self.setNeedsDisplay()
        }
        get {
            return _topLine!
        }
    }
    
    public var width:CGFloat {
        set {
            _width = newValue
            self.setNeedsDisplay()
        }
        get {
            return _width!
        }
    }
    
    public var height:CGFloat {
        set {
            _height = newValue
            self.setNeedsDisplay()
        }
        get {
            return _height!
        }
    }
    
    public var color:NSString {
        set {
            _color = newValue
            self.setNeedsDisplay()
        }
        get {
            return _color!
        }
    }
    
    public var lineColor:UIColor {
        set {
            _lineColor = newValue
            self.setNeedsDisplay()
        }
        get {
            return _lineColor!
        }
    }
    
    public var bgColor:UIColor {
        set {
            _bgColor = newValue
            self.setNeedsDisplay()
        }
        get {
            return _bgColor!
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        bgColor = UIColor.whiteColor()
        topLine = false
        xPosLine = 0.0
        width = frame.width
        height = frame.height
        self.contentMode = UIViewContentMode.Redraw
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func drawRect(rect: CGRect) {
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        let backgroundColor:UIColor =  UIColor.whiteColor()
        backgroundColor.set()
        CGContextFillRect(context, rect);
        
        CGContextSaveGState(context);
        let rectangle:CGRect = CGRectMake(0.0 , 0.0, _width!, _height!);
        CGContextAddRect(context, rectangle);
        CGContextSetFillColorWithColor(context, _bgColor!.CGColor);
        CGContextFillRect(context, rectangle);
        CGContextRestoreGState(context);
        
        if _topLine! {
            CGContextSetLineWidth(context, 1.0);
            CGContextSetStrokeColorWithColor(context, _lineColor!.CGColor);
            CGContextMoveToPoint(context, 0.0, 0.0);
            CGContextAddLineToPoint(context, _width!, 0.0);
            CGContextStrokePath(context);
        }
        
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, _lineColor!.CGColor);
        CGContextMoveToPoint(context, _xPosLine!, floor(rectangle.origin.y + rectangle.size.height));
        CGContextAddLineToPoint(context, _width!, floor(rectangle.origin.y + rectangle.size.height));
        CGContextStrokePath(context);
    }
}
