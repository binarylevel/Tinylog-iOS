//
//  TLIEditTaskViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIEditTaskViewController: UIViewController {
    
    var indexPath:NSIndexPath?
    var task:TLITask?
    var textView:UITextView?
    var keyboardRect:CGRect?
    var delegate:TLIEditTaskViewControllerDelegate?
    var tagsView:TLITagsView?
    var saveOnClose:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Task"
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Plain, target: self, action: "close:")
        
        let reminderButton:UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 22.0, 22.0))
        reminderButton.setBackgroundImage(UIImage(named: "728-clock-toolbar"), forState: UIControlState.Normal)
        reminderButton.addTarget(self, action: "displayReminder:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let reminderBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: reminderButton)
        let saveBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "save:")
        
        self.navigationItem.rightBarButtonItems = [saveBarButtonItem, reminderBarButtonItem]
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "save:")
        
        textView = UITextView(frame: CGRectZero)
        textView?.autocorrectionType = UITextAutocorrectionType.Yes
        textView?.bounces = true
        textView?.alwaysBounceVertical = true
        textView?.text = task?.displayLongText
        textView?.textColor = UIColor.tinylogTextColor()
        textView?.font = UIFont.tinylogFontOfSize(17.0)
        self.view.addSubview(textView!)
        
        let keyboardBar:TLIKeyboardBar = TLIKeyboardBar(frame: CGRectMake(0.0, 0.0, self.view.bounds.size.width, UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad ? 54.0 : 44.0))
        keyboardBar.keyInputView = textView
        textView?.inputAccessoryView = keyboardBar
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        keyboardRect = self.view.convertRect(userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue, fromView: nil)
        let duration:Double = userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey)!.doubleValue
        layoutTextView(duration)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        keyboardRect = CGRectZero
        let size:CGSize = self.view.bounds.size
        var heightAdjust:CGFloat
        
        if(UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
            heightAdjust = 2.0
        } else {
            heightAdjust = keyboardRect!.size.height
        }
        
        let textViewHeight = size.height - heightAdjust //- 44.0
        
        UIView.animateWithDuration(NSTimeInterval(userInfo.objectForKey(UIKeyboardAnimationDurationUserInfoKey)!.floatValue), delay: NSTimeInterval(0.0), options: [UIViewAnimationOptions.CurveEaseInOut,UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
            self.textView?.frame = CGRectMake(0.0, 0.0, size.width, textViewHeight)
            return
            }, completion: { (finished:Bool) -> Void in
                
        })
    }
    
    func close(sender:UIButton) {
        saveOnClose = false
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save(sender:UIButton) {
        saveOnClose = true
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        UIView.animateWithDuration(duration, delay: 0.0,
            options: .AllowUserInteraction, animations: {
                self.layoutTextView(duration)
            }, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardRect = CGRectZero
        layoutTextView(0.0)
        textView?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hideKeyboard()
        
        if saveOnClose {
            task?.displayLongText = textView!.text
            
            //Update notification
            if let _ = task?.notification {
                task!.notification!.displayText = task!.displayLongText
                task!.notification!.fireDate = task!.reminder!
                task!.notification!.updatedAt = NSDate()
            }
            
            let cdc:TLICDController = TLICDController.sharedInstance
            let total:NSString = textView!.text
            let words:NSArray = total.componentsSeparatedByString(" ")
            
            for word in words {
                let t = word as! NSString
                if t.hasPrefix("#") {
                    let value:NSString = t.substringWithRange(NSMakeRange(1, t.length - 1))
                    let tagModel:TLITag = TLITag.existing(value, context: cdc.context!)!
                    let tags:NSMutableSet = task?.valueForKeyPath("tags") as! NSMutableSet
                    tags.addObject(tagModel)
                } else if t.hasPrefix("@") {
                    let value:NSString = t.substringWithRange(NSMakeRange(1, t.length - 1))
                    let mention:TLIMention = TLIMention.existing(value, context: cdc.context!)!
                    let mentions:NSMutableSet = task?.valueForKeyPath("mentions") as! NSMutableSet
                    mentions.addObject(mention)
                }
            }
            
            cdc.backgroundSaveContext()
            
            delegate?.onClose(self, indexPath: indexPath!)
        }
    }
    
    func layoutTextView(duration:NSTimeInterval) {
        let size:CGSize = self.view.bounds.size
        var heightAdjust:CGFloat
        
        if(UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
            heightAdjust = 2.0
        } else {
            heightAdjust = keyboardRect!.size.height
        }
        
        let textViewHeight = size.height - heightAdjust //- 44.0
        
        UIView.animateWithDuration(NSTimeInterval(duration), delay: NSTimeInterval(0.0), options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
            self.textView?.frame = CGRectMake(0.0, 0.0, size.width, textViewHeight)
            return
            }, completion: { (finished:Bool) -> Void in
                
        })
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func displayReminder(button:UIButton) {
        let viewController:TLIReminderViewController = TLIReminderViewController()
        viewController.task = task
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
