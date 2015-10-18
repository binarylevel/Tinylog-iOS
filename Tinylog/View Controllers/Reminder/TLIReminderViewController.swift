//
//  TLIReminderViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import SVProgressHUD

class TLIReminderViewController: UIViewController {
    
    var task:TLITask?
    var isReminderRemoved = false
    var orientation:String = "portrait"
    
    lazy var datePicker:UIDatePicker? = {
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.center = self.view.center
        datePicker.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        datePicker.calendar = NSCalendar.currentCalendar()
        datePicker.minuteInterval = 15
        datePicker.addTarget(self, action: "changeDate:", forControlEvents: UIControlEvents.ValueChanged)
        return datePicker
        }()
    
    lazy var removeReminderButton:TLIRoundedButton? = {
        let removeReminderButton = TLIRoundedButton()
        removeReminderButton.setTitle("Remove", forState: UIControlState.Normal)
        removeReminderButton.backgroundColor = UIColor.tinylogTextColor()
        removeReminderButton.addTarget(self, action: "removeReminder:", forControlEvents: UIControlEvents.TouchDown)
        return removeReminderButton
        }()
    
    lazy var addReminderButton:TLIRoundedButton? = {
        let addReminderButton = TLIRoundedButton()
        addReminderButton.setTitle("Done", forState: UIControlState.Normal)
        addReminderButton.addTarget(self, action: "addReminder:", forControlEvents: UIControlEvents.TouchDown)
        addReminderButton.backgroundColor = UIColor.tinylogMainColor()
        return addReminderButton
        }()
    
    lazy var descriptionLabel:UILabel? = {
        let descriptionLabel:UILabel = UILabel(frame: CGRectMake(0.0, 74.0, self.view.frame.size.width, 64.0))
        descriptionLabel.lineBreakMode = .ByTruncatingTail
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .Center
        descriptionLabel.textColor = UIColor.tinylogMainColor()
        descriptionLabel.text = ""
        descriptionLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
        return descriptionLabel
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.title = "Reminder"
        
        if let reminder = task?.reminder {
            datePicker?.setDate(reminder, animated: false)
        } else {
            datePicker?.setDate(NSDate(), animated: false)
        }
        
        self.view.addSubview(descriptionLabel!)
        self.view.addSubview(removeReminderButton!)
        self.view.addSubview(addReminderButton!)
        self.view.addSubview(datePicker!)
        
        setDateText()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChanged", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func deviceOrientationChanged() {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            self.orientation = "landscape"
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            self.orientation = "portrait"
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName("TLIClearPassedNotifications", object: nil)
        
        if !isReminderRemoved {
            isReminderRemoved = false
            
            let cdc:TLICDController = TLICDController.sharedInstance
            
            if let notification = task?.notification { //Exists just update the notification
                task!.notification!.displayText = task!.displayLongText
                task!.notification!.fireDate = task!.reminder!
                task!.notification!.updatedAt = NSDate()
            } else {
                if let reminder = task!.reminder {
                    
                    let notification:TLINotification = NSEntityDescription.insertNewObjectForEntityForName("Notification", inManagedObjectContext: cdc.context!) as! TLINotification
                    notification.displayText = task!.displayLongText
                    notification.fireDate = task!.reminder!
                    notification.createdAt = NSDate()
                    notification.added = false
                    notification.updatedAt = nil
                    
                    //create the relationship
                    task?.notification = notification
                    //println("create new notification with \(notification.uniqueIdentifier)")
                }
            }
            
            //Save core date
            cdc.backgroundSaveContext()
            
            let syncManager:TLISyncManager = TLISyncManager.sharedSyncManager()
            if syncManager.canSynchronize() {
                syncManager.synchronizeWithCompletion { (error) -> Void in
                }
                
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(IDMSyncActivityDidEndNotification, object: nil)
            }
        }
    }
    
    func changeDate(sender:UIDatePicker) {
        let date:NSDate = datePicker!.date
        task?.reminder = date
        setDateText()
    }
    
    func setDateText() {
        let currentDate:NSDate
        
        if let reminder = task?.reminder {
            currentDate = reminder
        } else {
            currentDate = NSDate()
        }
        
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let strDate:String = dateFormatter.stringFromDate(currentDate)
        var time = calculateDates(currentDate)
        
        var redColor = UIColor(red: 254.0 / 255.0, green: 69.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
        
        if time == "Yesterday" {
            descriptionLabel?.textColor = redColor
        } else {
            descriptionLabel?.textColor = UIColor.tinylogMainColor()
        }
        
        descriptionLabel!.text = "\(time) at \(strDate)"
    }
    
    func calculateDates(date:NSDate)->String {
        if date.isToday() {
            return "Today"
        } else if date.isTomorrow() {
            return "Tomorrow"
        } else if date.isYesterday() {
            return "Yesterday"
        } else if date.isWeekend() {
            return "Weekend"
        } else if date.isThisWeek() {
            return "This Week"
        } else if date.isNextWeek() {
            return "Next Week"
        } else if date.isLastWeek() {
            return "Last Week"
        } else if date.isThisMonth() {
            return "This Month"
        } else if date.isNextMonth() {
            return "Next Month"
        } else if date.isLastMonth() {
            return "Last Month"
        } else if date.isLastYear() {
            return "Last Year"
        } else if date.isNextYear() {
            return "Next Year"
        } else if date.isThisYear() {
            return "This Year"
        }
        return ""
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            self.orientation = "landscape"
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            self.orientation = "portrait"
        }
        
        var screenHeight = UIScreen.mainScreen().bounds.size.height
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        if screenHeight < screenWidth {
            screenHeight = screenWidth
        }
        
        if self.orientation == "portrait" {
            
            let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
            
            if IS_IPAD {
                descriptionLabel?.frame = CGRectMake(0.0, 100.0, self.view.frame.size.width, 64.0)
            } else {
                if screenHeight > 480 && screenHeight < 667 { //iPhone 5/5s
                    descriptionLabel?.frame = CGRectMake(0.0, 100.0, self.view.frame.size.width, 64.0)
                } else if screenHeight > 480 && screenHeight < 736 { //iPhone 6
                    descriptionLabel?.frame = CGRectMake(0.0, 120.0, self.view.frame.size.width, 64.0)
                } else if ( screenHeight > 480 ){ //iPhone 6 Plus
                    descriptionLabel?.frame = CGRectMake(0.0, 140.0, self.view.frame.size.width, 64.0)
                } else { //iPhone 4/4s
                    descriptionLabel?.frame = CGRectMake(0.0, 74.0, self.view.frame.size.width, 64.0)
                }
            }
            
        } else {
            
            let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
            
            if IS_IPAD {
                descriptionLabel?.frame = CGRectMake(0.0, 100.0, self.view.frame.size.width, 64.0)
            } else {
                if screenHeight > 480 && screenHeight < 667 { //iPhone 5/5s
                    descriptionLabel?.frame = CGRectMake(0.0, 26.0, self.view.frame.size.width, 64.0)
                } else if screenHeight > 480 && screenHeight < 736 { //iPhone 6
                    descriptionLabel?.frame = CGRectMake(0.0, 42.0, self.view.frame.size.width, 64.0)
                } else if ( screenHeight > 480 ){ //iPhone 6 Plus
                    descriptionLabel?.frame = CGRectMake(0.0, 60.0, self.view.frame.size.width, 64.0)
                } else { //iPhone 4/4s
                    descriptionLabel?.frame = CGRectMake(0.0, 26.0, self.view.frame.size.width, 64.0)
                }
            }
        }
        
        datePicker?.frame = CGRectMake(0.0, round(self.view.frame.size.height / 2.0 - datePicker!.frame.size.height / 2.0), self.view.frame.size.width, 0.0)
        removeReminderButton!.frame = CGRectMake(0.0, self.view.frame.size.height - 55.0, self.view.frame.size.width / 2.0, 55.0)
        addReminderButton!.frame = CGRectMake(removeReminderButton!.frame.origin.x + removeReminderButton!.frame.size.width, self.view.frame.size.height - 55.0, self.view.frame.size.width / 2.0, 55.0)
    }
    
    func removeReminder(sender:TLIRoundedButton) {
        isReminderRemoved = true
        task?.reminder = nil
        TLICDController.sharedInstance.backgroundSaveContext()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func addReminder(sender:TLIRoundedButton) {
        let date:NSDate = datePicker!.date
        task?.reminder = date
        
        if task?.reminder?.timeIntervalSinceNow < 0 {
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
            SVProgressHUD.setBackgroundColor(UIColor.tinylogMainColor())
            SVProgressHUD.setForegroundColor(UIColor.whiteColor())
            SVProgressHUD.setFont(UIFont(name: "HelveticaNeue", size: 14.0))
            SVProgressHUD.showErrorWithStatus("Please select a time in the near future")
        } else {
            setDateText()
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        TLIAnalyticsTracker.trackMixpanelEvent("Add Reminder", properties: nil)
    }
}

