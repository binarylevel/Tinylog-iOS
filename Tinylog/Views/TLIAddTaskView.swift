//
//  TLIAddTaskView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIAddTaskView: UIView, UITextFieldDelegate {
    
    var textField:TLITextField? = {
        let textField = TLITextField.newAutoLayoutView()
        textField.backgroundColor = UIColor.clearColor()
        textField.font = UIFont.tinylogFontOfSize(17.0)
        textField.textColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        textField.placeholder = "Add new task"
        textField.setValue(UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0), forKeyPath: "_placeholderLabel.textColor")
        textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
        textField.autocorrectionType = UITextAutocorrectionType.Yes
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        textField.textAlignment = NSTextAlignment.Left
        textField.returnKeyType = UIReturnKeyType.Done
        textField.tintColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        return textField
    }()
    
    var closeButton:TLICloseButton? = {
        let closeButton = TLICloseButton.newAutoLayoutView()
        closeButton.hidden = true
        return closeButton
    }()
    
    var delegate:TLIAddTaskViewDelegate?
    var didSetupContraints = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.backgroundColor = UIColor.tinylogMainColor()
        
        textField!.delegate = self
        self.addSubview(textField!)
        
        self.addSubview(closeButton!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFonts", name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
        
        setNeedsUpdateConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func updateConstraints() {
        
        let smallPadding:CGFloat = 16.0
        
        if !didSetupContraints {
            
            textField!.autoPinEdgeToSuperviewEdge(.Top, withInset: 10.0)
            textField!.autoPinEdgeToSuperviewEdge(.Leading, withInset: 16.0)
            textField!.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 50.0)
            textField!.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 10.0)

            closeButton?.autoSetDimensionsToSize(CGSize(width: 18.0, height: 18.0))
            closeButton?.autoAlignAxisToSuperviewAxis(.Horizontal)
            closeButton?.autoPinEdgeToSuperviewEdge(.Right, withInset: smallPadding)
            
            didSetupContraints = true
        }
        super.updateConstraints()
    }
}

