//
//  SGTextField.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 21/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class SGTextField: UITextField {

    var placeholderTextColor:UIColor?
    var textEdgeInsets:UIEdgeInsets?
    var clearButtonEdgeInsets:UIEdgeInsets?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        textEdgeInsets = UIEdgeInsetsZero
        clearButtonEdgeInsets = UIEdgeInsetsZero
    }
    
    // MARK: UITextField
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(super.textRectForBounds(bounds), textEdgeInsets!)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.textRectForBounds(bounds)
    }
    
    override func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRectForBounds(bounds)
        rect = CGRectSetY(rect, rect.origin.y + (clearButtonEdgeInsets?.top)!)
        return CGRectSetX(rect, rect.origin.x + (clearButtonEdgeInsets?.right)!)
    }
}

