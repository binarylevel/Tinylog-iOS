//
//  TLIReminderTaskTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SGBackgroundView

class TLIReminderTaskTableViewCell: TLITableViewCell {
    
    let kLabelHorizontalInsets: CGFloat = 60.0
    let kLabelVerticalInsets: CGFloat = 10.0
    var didSetupConstraints = false
    let taskLabel:TTTAttributedLabel = TTTAttributedLabel.newAutoLayoutView()
    let dateLabel:TTTAttributedLabel = TTTAttributedLabel.newAutoLayoutView()
    var bgView:SGBackgroundView?
    
    let checkBoxButton:TLICheckBoxButton = TLICheckBoxButton.newAutoLayoutView()
    var checkMarkIcon:UIImageView?
    
    var currentTask:TLITask? {
        didSet {
            
            //Fetch all objects from list
            let cdc:TLICDController = TLICDController.sharedInstance
            let fetchRequestTotal:NSFetchRequest = NSFetchRequest(entityName: "Task")
            let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
            fetchRequestTotal.sortDescriptors = [positionDescriptor]
            fetchRequestTotal.predicate  = NSPredicate(format: "archivedAt = nil AND list = %@", currentTask!.list!)
            fetchRequestTotal.fetchBatchSize = 20
            
            do {
                let results:NSArray = try cdc.context!.executeFetchRequest(fetchRequestTotal)
                
                let fetchRequestCompleted:NSFetchRequest = NSFetchRequest(entityName: "Task")
                fetchRequestCompleted.sortDescriptors = [positionDescriptor]
                fetchRequestCompleted.predicate  = NSPredicate(format: "archivedAt = nil AND completed = %@ AND list = %@", NSNumber(bool: true), currentTask!.list!)
                fetchRequestCompleted.fetchBatchSize = 20
                let resultsCompleted:NSArray = try cdc.context!.executeFetchRequest(fetchRequestCompleted)
                
                let total:Int = results.count - resultsCompleted.count
                currentTask?.list!.total = total
                
                checkBoxButton.circleView?.layer.borderColor = UIColor(rgba: currentTask!.list!.color!).CGColor
                checkBoxButton.checkMarkIcon?.image = checkBoxButton.checkMarkIcon?.image?.imageWithColor(UIColor(rgba: currentTask!.list!.color!))

            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
            
            //set reminder
            if let now = currentTask?.reminder {
                let time = calculateDates(now)
                let dateFormatter:NSDateFormatter = NSDateFormatter()
                //dateFormatter.timeZone = NSTimeZone.systemTimeZone()
                //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                //dateFormatter.dateFormat = "HH:mm a"
                dateFormatter.dateFormat = "h:mm a"
                let strDate:String = dateFormatter.stringFromDate(currentTask!.reminder!)
                
                if let boolValue = currentTask?.completed?.boolValue {
                    if boolValue && currentTask!.reminder?.timeIntervalSinceNow < 0 {
                        //println("1 task \(currentTask?.displayLongText) is checked and time has passed")
                        dateLabel.textColor = UIColor.lightGrayColor()
                    } else if !boolValue && currentTask!.reminder?.timeIntervalSinceNow > 0 {
                        //println("2 task is not checked and time has not passed")
                        dateLabel.textColor = UIColor.tinylogMainColor()
                    } else if boolValue && currentTask!.reminder?.timeIntervalSinceNow > 0 {
                        //println("3 task is checked and time has not passed")
                        dateLabel.textColor = UIColor.lightGrayColor()
                    } else if !boolValue && currentTask!.reminder?.timeIntervalSinceNow < 0 {
                        //println("4 task \(currentTask?.displayLongText) is not checked and time has passed")
                        dateLabel.textColor = UIColor(red: 254.0 / 255.0, green: 69.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
                    }
                }
                
                dateLabel.text = "\(time) at \(strDate)"
            }
            
            updateFonts()
            
            taskLabel.activeLinkAttributes = [kCTForegroundColorAttributeName: UIColor(rgba: currentTask!.list!.color!)]
            
            if let boolValue = currentTask?.completed?.boolValue {
                if boolValue {
                    checkBoxButton.checkMarkIcon!.hidden = false
                    checkBoxButton.alpha = 0.5
                    taskLabel.textColor = UIColor.lightGrayColor()
                    taskLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor.lightGrayColor()]
                } else {
                    checkBoxButton.checkMarkIcon!.hidden = true
                    checkBoxButton.alpha = 1.0
                    taskLabel.textColor = UIColor.tinylogTextColor()
                    taskLabel.linkAttributes = [kCTForegroundColorAttributeName: UIColor(rgba: currentTask!.list!.color!)]
                }
            }
            
            updateAttributedText()
            
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView = SGBackgroundView(frame: CGRectZero)
        bgView?.bgColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        bgView?.lineColor = UIColor(red: 224.0 / 255.0, green: 224.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
        bgView?.xPosLine = 16.0
        self.backgroundView = bgView!
        
        taskLabel.lineBreakMode = .ByTruncatingTail
        taskLabel.numberOfLines = 0
        taskLabel.textAlignment = .Left
        taskLabel.textColor = UIColor.tinylogTextColor()
        contentView.addSubview(taskLabel)
        
        dateLabel.lineBreakMode = .ByTruncatingTail
        dateLabel.numberOfLines = 1
        dateLabel.textAlignment = .Left
        dateLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(dateLabel)
        
        checkBoxButton.tableViewCell = self
        self.contentView.addSubview(checkBoxButton)
        
        updateFonts()
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
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
//            UIView.autoSetPriority(1000) {
//                self.checkBoxButton.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
//                self.taskLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
//                self.dateLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
//            }
            
            dateLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 18.0)
            dateLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: 16.0)
            dateLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 50.0)
            
            taskLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: dateLabel, withOffset: 5.0, relation: .GreaterThanOrEqual)
            taskLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: 16.0)
            taskLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 50.0)
            taskLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 18.0)
            
            checkBoxButton.autoSetDimensionsToSize(CGSizeMake(30.0, 30.0))
            checkBoxButton.autoAlignAxis(.Horizontal, toSameAxisOfView: self.contentView, withOffset: 0.0)
            checkBoxButton.autoPinEdge(.Left, toEdge: .Right, ofView: taskLabel, withOffset: 10.0)
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
    
    override func updateFonts() {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let useSystemFontSize:String = userDefaults.objectForKey("kSystemFontSize") as! String
        
        if useSystemFontSize == "on" {
            if TLISettingsFontPickerViewController.selectedKey() == "Avenir" {
                taskLabel.font = UIFont.preferredAvenirFontForTextStyle(UIFontTextStyleBody)
                dateLabel.font = UIFont.preferredAvenirFontForTextStyle(UIFontTextStyleHeadline)
            } else if TLISettingsFontPickerViewController.selectedKey() == "HelveticaNeue" {
                taskLabel.font = UIFont.preferredHelveticaNeueFontForTextStyle(UIFontTextStyleBody)
                dateLabel.font = UIFont.preferredHelveticaNeueFontForTextStyle(UIFontTextStyleHeadline)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Courier" {
                taskLabel.font = UIFont.preferredCourierFontForTextStyle(UIFontTextStyleBody)
                dateLabel.font = UIFont.preferredCourierFontForTextStyle(UIFontTextStyleHeadline)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Georgia" {
                taskLabel.font = UIFont.preferredGeorgiaFontForTextStyle(UIFontTextStyleBody)
                dateLabel.font = UIFont.preferredGeorgiaFontForTextStyle(UIFontTextStyleHeadline)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Menlo" {
                taskLabel.font = UIFont.preferredMenloFontForTextStyle(UIFontTextStyleBody)
                dateLabel.font = UIFont.preferredMenloFontForTextStyle(UIFontTextStyleHeadline)
            } else if TLISettingsFontPickerViewController.selectedKey() == "TimesNewRoman" {
                taskLabel.font = UIFont.preferredTimesNewRomanFontForTextStyle(UIFontTextStyleBody)
                dateLabel.font = UIFont.preferredTimesNewRomanFontForTextStyle(UIFontTextStyleHeadline)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Palatino" {
                taskLabel.font = UIFont.preferredPalatinoFontForTextStyle(UIFontTextStyleBody)
                dateLabel.font = UIFont.preferredPalatinoFontForTextStyle(UIFontTextStyleHeadline)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Iowan" {
                taskLabel.font = UIFont.preferredIowanFontForTextStyle(UIFontTextStyleBody)
                dateLabel.font = UIFont.preferredIowanFontForTextStyle(UIFontTextStyleHeadline)
            }
        } else {
            let fontSize:Float = userDefaults.floatForKey("kFontSize")
            taskLabel.font = UIFont.tinylogFontOfSize(CGFloat(fontSize))
            dateLabel.font = UIFont.boldTinylogFontOfSize(CGFloat(fontSize - 1.0))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size:CGSize = self.contentView.bounds.size
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
        taskLabel.preferredMaxLayoutWidth = CGRectGetWidth(taskLabel.frame)
        
        if self.editing {
            bgView?.width = size.width + 78.0
            bgView?.height = size.height
        } else {
            bgView?.width = size.width
            bgView?.height = size.height
        }
    }
    
    func updateAttributedText() {
        
        taskLabel.setText(currentTask?.displayLongText, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString) -> NSMutableAttributedString! in
            return mutableAttributedString;
        })
        
        if let text = taskLabel.text {
            let total:NSString = text as NSString
            let words:NSArray = total.componentsSeparatedByString(" ")
            
            for word in words {
                let character = word as! NSString
                if character.hasPrefix("#") {
                    let value:NSString = character.substringWithRange(NSMakeRange(1, character.length - 1))
                    let range:NSRange = total.rangeOfString(character as String)
                    let url:NSURL = NSURL(string: NSString(format: "tag://%@", value) as String)!
                    let tagModel:TLITag = TLITag.existing(value, context: currentTask!.managedObjectContext!)!
                    let tags:NSMutableSet = currentTask?.valueForKeyPath("tags") as! NSMutableSet
                    tags.addObject(tagModel)
                    taskLabel.addLinkToURL(url, withRange: range)
                } else if character.hasPrefix("http://") || character.hasPrefix("https://") {
                    let value:NSString = character.substringWithRange(NSMakeRange(0, character.length))
                    let range:NSRange = total.rangeOfString(character as String)
                    let url:NSURL = NSURL(string: NSString(format: "%@", value) as String)!
                    taskLabel.addLinkToURL(url, withRange: range)
                } else if character.hasPrefix("@") {
                    let value:NSString = character.substringWithRange(NSMakeRange(1, character.length - 1))
                    let range:NSRange = total.rangeOfString(character as String)
                    let url:NSURL = NSURL(string: NSString(format: "mention://%@", value) as String)!
                    let mention:TLIMention = TLIMention.existing(value, context: currentTask!.managedObjectContext!)!
                    let mentions:NSMutableSet = currentTask?.valueForKeyPath("mentions") as! NSMutableSet
                    mentions.addObject(mention)
                    taskLabel.addLinkToURL(url, withRange: range)
                }
            }
        }
    }
}

