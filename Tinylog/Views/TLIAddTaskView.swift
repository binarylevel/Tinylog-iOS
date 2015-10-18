//
//  TLIAddTaskView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

//
//  TLIAddTaskView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 10/8/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIAddTaskView: UIView, UITextFieldDelegate {
    
    var textField:TLITextField?
    var tagsContainerView:UIView?
    var taskContainerView:UIView?
    var tagsView:TLITagsView?
    var delegate:TLIAddTaskViewDelegate?
    var closeButton:TLICloseButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.backgroundColor = UIColor.tinylogMainColor()
        
        textField = TLITextField(frame: CGRectZero)
        textField?.backgroundColor = UIColor.clearColor()
        textField?.font = UIFont.tinylogFontOfSize(17.0)
        textField?.textColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        textField?.placeholder = "Add new task"
        textField?.setValue(UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0), forKeyPath: "_placeholderLabel.textColor")
        textField?.autocapitalizationType = UITextAutocapitalizationType.Sentences
        textField?.autocorrectionType = UITextAutocorrectionType.Yes
        textField?.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        textField?.textAlignment = NSTextAlignment.Left
        textField?.returnKeyType = UIReturnKeyType.Done
        textField?.delegate = self
        textField?.tintColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.addSubview(textField!)
        
        closeButton = TLICloseButton()
        closeButton?.hidden = true
        self.addSubview(closeButton!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFonts", name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size:CGSize = self.bounds.size
        textField?.frame = CGRectMake(17.0, 0.0, size.width - 17.0, TLIAddTaskView.height())
        closeButton?.frame = CGRectMake(size.width - 34.0, size.height  / 2.0 - 18.0 / 2.0, 18.0, 18.0)
    }
    
    class func height()->CGFloat {
        return 44.0
    }
    
    func updateFonts() {
        textField?.font = UIFont.tinylogFontOfSize(17.0)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.addTaskViewDidBeginEditing!(self)
        textField.placeholder = ""
        closeButton?.hidden = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        delegate?.addTaskViewDidEndEditing!(self)
        textField.placeholder = "Add new task"
        closeButton?.hidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text!.length() == 0 {
            textField.resignFirstResponder()
            return false
        }
        
        let title:NSString = textField.text!
        textField.text = nil
        delegate?.addTaskView(self, title: title)
        return false
    }
}

