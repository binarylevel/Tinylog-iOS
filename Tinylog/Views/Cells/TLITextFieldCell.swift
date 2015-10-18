//
//  TLITextFieldCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLITextFieldCell: UITableViewCell, UITextFieldDelegate, TLITextFieldCellDelegate {
    
    var textField:TLITextField?
    var indexPath:NSIndexPath?
    var delegate:TLITextFieldCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        
        textField = TLITextField(frame: CGRectZero)
        textField?.clearsOnBeginEditing = false
        textField?.clearButtonMode = UITextFieldViewMode.WhileEditing
        textField?.textAlignment = NSTextAlignment.Left
        textField?.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        textField?.keyboardAppearance = UIKeyboardAppearance.Light
        textField?.adjustsFontSizeToFitWidth = true
        textField?.delegate = self
        textField?.font = UIFont.regularFontWithSize(17.0)
        textField?.textColor = UIColor.tinylogTextColor()
        self.contentView.addSubview(textField!)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        delegate = nil
        textField?.resignFirstResponder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frame:CGRect = self.contentView.frame
        
        if textField?.text != nil || textField?.placeholder != nil {
            textField?.hidden = false
            textField?.frame = CGRectMake(frame.origin.x + 16.0, frame.origin.y, frame.size.width, frame.size.height)
            textField?.autocapitalizationType = UITextAutocapitalizationType.None
        }
        self.setNeedsDisplay()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let value = delegate?.shouldReturnForIndexPath!(indexPath!, value: textField.text!)
        if value != nil {
            textField.resignFirstResponder()
        }
        return value!
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var textString:NSString = textField.text!
        textString = textString.stringByReplacingCharactersInRange(range, withString: string)
        delegate?.updateTextLabelAtIndexPath!(indexPath!, value: textString as String)
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        delegate?.updateTextLabelAtIndexPath!(indexPath!, value: textField.text!)
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        delegate?.textFieldShouldBeginEditing!(textField)
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        delegate?.textFieldShouldEndEditing!(textField)
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.textFieldDidBeginEditing!(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        delegate?.textFieldDidEndEditing!(textField)
    }
}

