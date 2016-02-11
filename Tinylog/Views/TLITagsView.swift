//
//  TLITagsView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLITagsView: UIView, UITextFieldDelegate {
    
    var items:NSMutableArray?
    var tagsObject:NSMutableArray?
    var scrollView:UIScrollView?
    
    init(frame: CGRect, tags:NSArray) {
        super.init(frame: frame)
        
        tagsObject = NSMutableArray()
        
        for item in tags {
            let tag:TLITag = item as! TLITag
            tagsObject?.addObject(tag.name!)
        }
        
        tagsObject?.addObject("New Tag")
        
        scrollView = UIScrollView(frame: CGRectMake(0.0, 0.0, self.frame.size.width, 44.0))
        scrollView?.backgroundColor = UIColor.lightGrayColor()
        scrollView?.scrollEnabled = true
        scrollView?.clipsToBounds = true
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.bounces = true
        scrollView?.alwaysBounceHorizontal = true
        scrollView?.alwaysBounceVertical = false
        self.addSubview(scrollView!)
        
        createTags()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func createTags() {
        items = NSMutableArray()
        
        let count = tagsObject?.count
        let lastObject:AnyObject = tagsObject!.lastObject!
        
        var xOffset:CGFloat = 0
        let xButtonBuffer:CGFloat = 5.0
        
        for var i = 0; i < count; i++ {
            
            let font:UIFont = UIFont(name: "Avenir-Book", size: 16.0)!
            let text:NSString = tagsObject?.objectAtIndex(i) as! NSString
            let textField:TLITextField = TLITextField()
            textField.delegate = self
            textField.font = font
            textField.text = text as String
            
            if text == lastObject as! NSString {
                textField.tag = 1000
                textField.backgroundColor = UIColor.redColor()
            } else {
                textField.backgroundColor = UIColor.blackColor()
            }
            
            let size: CGSize = text.sizeWithAttributes([NSFontAttributeName: font])
            let stringWidth = size.width + 40
            let stringHeight = size.height + 10
            
            textField.frame = CGRectMake(xOffset, 44.0 / 2.0 - stringHeight / 2.0, stringWidth, stringHeight)
            textField.textEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
            textField.layer.cornerRadius = textField.frame.size.height / 2.0
            
            scrollView?.addSubview(textField)
            items?.addObject(textField)
            
            xOffset += stringWidth + xButtonBuffer
            
        }
        
        scrollView?.contentSize = CGSizeMake(xOffset, 44.0)
        scrollView?.setNeedsDisplay()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 1000 {
            let txt = textField as! TLITextField
            txt.textEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
}

