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
    var didSetupContraints = false
    
    lazy var datePicker:UIDatePicker = {
        let datePicker:UIDatePicker = UIDatePicker.newAutoLayoutView()
        datePicker.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        datePicker.calendar = NSCalendar.currentCalendar()
        datePicker.minuteInterval = 15
        datePicker.addTarget(self, action: "changeDate:", forControlEvents: UIControlEvents.ValueChanged)
        return datePicker
    }()
    
    lazy var removeReminderButton:TLIRoundedButton = {
        let removeReminderButton = TLIRoundedButton.newAutoLayoutView()
        removeReminderButton.setTitle("Remove", forState: UIControlState.Normal)
        removeReminderButton.backgroundColor = UIColor.tinylogTextColor()
        removeReminderButton.addTarget(self, action: "removeReminder:", forControlEvents: UIControlEvents.TouchDown)
        return removeReminderButton
    }()
    
    lazy var addReminderButton:TLIRoundedButton = {
        let addReminderButton = TLIRoundedButton.newAutoLayoutView()
        addReminderButton.setTitle("Done", forState: UIControlState.Normal)
        addReminderButton.addTarget(self, action: "addReminder:", forControlEvents: UIControlEvents.TouchDown)
        addReminderButton.backgroundColor = UIColor.tinylogMainColor()
        return addReminderButton
    }()
    
    lazy var descriptionLabel:UILabel = {
        let descriptionLabel:UILabel = UILabel.newAutoLayoutView()
        descriptionLabel.lineBreakMode = .ByTruncatingTail
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .Center
        descriptionLabel.textColor = UIColor.tinylogMainColor()
        descriptionLabel.text = ""
        descriptionLabel.font = UIFont.mediumFontWithSize(20.0)
        return descriptionLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.title = "Reminder"
        
        if let reminder = task?.reminder {
            datePicker.setDate(reminder, animated: false)
        } else {
            datePicker.setDate(NSDate(), animated: false)
        }
     
        setDateText()
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(descriptionLabel)
        view.addSubview(datePicker)
        view.addSubview(addReminderButton)
        view.addSubview(removeReminderButton)
        view.setNeedsUpdateConstraints()
    }
        
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName("TLIClearPassedNotifications", object: nil)
        
        if !isReminderRemoved {
            isReminderRemoved = false
            
            let cdc:TLICDController = TLICDController.sharedInstance
            
            if let notification = task?.notification { //Exists just update the notification
                notification.displayText = task!.displayLongText
                notification.fireDate = task!.reminder!
                notification.updatedAt = NSDate()
            } else {
                if let reminder = task!.reminder {
                    
                    let notification:TLINotification = NSEntityDescription.insertNewObjectForEntityForName("Notification", inManagedObjectContext: cdc.context!) as! TLINotification
                    notification.displayText = task!.displayLongText
                    notification.fireDate = reminder
                    notification.createdAt = NSDate()
                    notification.added = false
                    notification.updatedAt = nil
                    
                    //create the relationship
                    task?.notification = notification
                }
            }
        
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
        let date:NSDate = datePicker.date
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
        let time = calculateDates(currentDate)
        
        let redColor = UIColor(red: 254.0 / 255.0, green: 69.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
        
        if time == "Yesterday" {
            descriptionLabel.textColor = redColor
        } else {
            descriptionLabel.textColor = UIColor.tinylogMainColor()
        }
        
        descriptionLabel.text = "\(time) at \(strDate)"
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
    }
    
    func removeReminder(sender:TLIRoundedButton) {
        isReminderRemoved = true
        task?.reminder = nil
        TLICDController.sharedInstance.backgroundSaveContext()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func addReminder(sender:TLIRoundedButton) {
        let date:NSDate = datePicker.date
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
    
    override func updateViewConstraints() {
        
        let smallPadding: CGFloat = 20.0
        
        if !didSetupContraints {
            
            descriptionLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        
            descriptionLabel.autoPinToTopLayoutGuideOfViewController(self, withInset: smallPadding)
            descriptionLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: smallPadding)
            descriptionLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: smallPadding)
            
            datePicker.autoCenterInSuperview()
            
            addReminderButton.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view, withMultiplier: 0.5)
            addReminderButton.autoSetDimension(.Height, toSize: 55.0)
            addReminderButton.autoPinEdgeToSuperviewEdge(.Left)
            addReminderButton.autoPinEdgeToSuperviewEdge(.Bottom)
            
            removeReminderButton.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view, withMultiplier: 0.5)
            removeReminderButton.autoSetDimension(.Height, toSize: 55.0)
            removeReminderButton.autoPinEdgeToSuperviewEdge(.Bottom)
            removeReminderButton.autoPinEdge(.Left, toEdge: .Right, ofView: addReminderButton)
            
            didSetupContraints = true
        }
        super.updateViewConstraints()
    }
}

