//
//  TLITableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLITableViewCell: UITableViewCell {
    
    var editingText:Bool?
    var editingTapGestureRecognizer:UITapGestureRecognizer?
    var editingLongPressGestureRecognizer:UILongPressGestureRecognizer?
    
    var textField:TLITextField? {
        didSet {
            if !(textField != nil) {
                textField = TLITextField(frame: CGRectZero)
                textField?.textColor = self.textLabel!.textColor
                textField?.placeholderTextColor = UIColor.tinylogNavigationBarColor()
                textField?.backgroundColor = UIColor.whiteColor()
                textField?.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
                textField?.returnKeyType = UIReturnKeyType.Done
                textField?.alpha = 0.0
                self.updateFonts()
                self.contentView.addSubview(textField!)
            }
        }
    }
    
    func setEditingText(editingText:Bool) {
        self.editingText = editingText
        
        if self.editingText! {
            
            self.contentView.addSubview(self.textField!)
            self.setNeedsLayout()
            textField?.becomeFirstResponder()
            
            UIView.animateWithDuration(NSTimeInterval(0.4), delay: NSTimeInterval(0.0), options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.textField?.alpha = 1
                return
                }, completion: { (finished:Bool) -> Void in
                    
            })
            
        } else {
            textField?.resignFirstResponder()
            UIView.animateWithDuration(NSTimeInterval(0.4), delay: NSTimeInterval(0.0), options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.textField?.alpha = 0.0
                return
                }, completion: { (finished:Bool) -> Void in
                    self.textField?.removeFromSuperview()
                    self.textField = nil
            })
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel!.textColor = UIColor.tinylogTextColor()
        self.updateFonts()
        
        self.contentView.clipsToBounds = true
        
        editingTapGestureRecognizer = UITapGestureRecognizer()
        editingTapGestureRecognizer?.delegate = self
        self.addGestureRecognizer(editingTapGestureRecognizer!)
        
        editingLongPressGestureRecognizer = UILongPressGestureRecognizer()
        editingLongPressGestureRecognizer?.delegate = self
        self.addGestureRecognizer(editingLongPressGestureRecognizer!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TLITableViewCell.updateFonts), name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if !selected {
            self.textLabel!.backgroundColor = UIColor.clearColor()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setEditingText(false)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editingTapGestureRecognizer?.enabled = editing
    }
    
    class func cellHeight()->CGFloat {
        return 51.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size:CGSize = self.contentView.bounds.size
        
        if self.editing {
            textField?.frame = CGRectMake(14.0, 0.0, size.width - 46.0, size.height - 2.0)
        }
    }
    
    func updateFonts() {
        textField?.font = self.textLabel!.font
        self.textLabel!.font = UIFont.tinylogFontOfSize(18.0)
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return touch.view!.isKindOfClass(UIControl.self) == false
    }
    
    func setEditingAction(editAction:Selector, target:AnyObject) {
        editingTapGestureRecognizer?.addTarget(target, action: editAction)
        editingLongPressGestureRecognizer?.addTarget(target, action: editAction)
    }
}

