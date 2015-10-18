//
//  TLIListTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SGBackgroundView

class TLIListTableViewCell: TLITableViewCell {
    
    let kRadius:CGFloat = 30.0
    var didSetupConstraints = false
    var bgView:SGBackgroundView?
    let listLabel:TTTAttributedLabel = TTTAttributedLabel.newAutoLayoutView()
    let totalTasksLabel:TTTAttributedLabel = TTTAttributedLabel.newAutoLayoutView()
    var checkBoxButton:TLICheckBoxButton?
    
    var currentList:TLIList? {
        didSet {
            updateFonts()
            
            self.listLabel.text = currentList?.title
            let total:Int = currentList!.total as! Int
            
            self.totalTasksLabel.text = String(total)
            totalTasksLabel.layer.borderColor = UIColor(rgba: currentList!.color!).CGColor
            self.totalTasksLabel.textColor = UIColor(rgba: currentList!.color!)
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()
        }
        willSet {
            self.totalTasksLabel.textColor = UIColor(rgba: newValue!.color!)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.currentList = nil
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView = SGBackgroundView(frame: CGRectZero)
        bgView?.bgColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        bgView?.lineColor = UIColor(red: 213.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
        bgView?.xPosLine = 16.0
        self.backgroundView = bgView!
        
        listLabel.lineBreakMode = .ByTruncatingTail
        listLabel.numberOfLines = 0
        listLabel.textAlignment = .Left
        listLabel.textColor = UIColor.tinylogTextColor()
        self.contentView.addSubview(listLabel)
        
        totalTasksLabel.layer.cornerRadius = kRadius / 2.0
        totalTasksLabel.layer.borderColor = UIColor.lightGrayColor().CGColor
        totalTasksLabel.layer.borderWidth = 1.0
        totalTasksLabel.textAlignment = NSTextAlignment.Center
        totalTasksLabel.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        totalTasksLabel.clipsToBounds = true
        self.contentView.addSubview(totalTasksLabel)
        
        let selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.backgroundColor = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        selectedBackgroundView.contentMode = UIViewContentMode.Redraw
        self.selectedBackgroundView = selectedBackgroundView
        
        updateFonts()
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
//            UIView.autoSetPriority(1000) {
//                self.totalTasksLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
//                self.listLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
//            }
            
            listLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 20.0)
            listLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: 16.0)
            listLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 50.0)
            listLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 20.0)
            
            totalTasksLabel.autoSetDimensionsToSize(CGSizeMake(kRadius, kRadius))
            totalTasksLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: self.contentView, withOffset: 0.0)
            totalTasksLabel.autoPinEdge(.Left, toEdge: .Right, ofView: listLabel, withOffset: 10.0)
            
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
    override func updateFonts() {
        super.updateFonts()
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let useSystemFontSize:String = userDefaults.objectForKey("kSystemFontSize") as! String
        
        if useSystemFontSize == "on" {
            if TLISettingsFontPickerViewController.selectedKey() == "Avenir" {
                listLabel.font = UIFont.preferredAvenirFontForTextStyle(UIFontTextStyleBody)
                totalTasksLabel.font = UIFont.preferredAvenirFontForTextStyle(UIFontTextStyleBody)
            } else if TLISettingsFontPickerViewController.selectedKey() == "HelveticaNeue" {
                listLabel.font = UIFont.preferredHelveticaNeueFontForTextStyle(UIFontTextStyleBody)
                totalTasksLabel.font = UIFont.preferredHelveticaNeueFontForTextStyle(UIFontTextStyleBody)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Courier" {
                listLabel.font = UIFont.preferredCourierFontForTextStyle(UIFontTextStyleBody)
                totalTasksLabel.font = UIFont.preferredCourierFontForTextStyle(UIFontTextStyleBody)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Georgia" {
                listLabel.font = UIFont.preferredGeorgiaFontForTextStyle(UIFontTextStyleBody)
                totalTasksLabel.font = UIFont.preferredGeorgiaFontForTextStyle(UIFontTextStyleBody)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Menlo" {
                listLabel.font = UIFont.preferredMenloFontForTextStyle(UIFontTextStyleBody)
                totalTasksLabel.font = UIFont.preferredMenloFontForTextStyle(UIFontTextStyleBody)
            } else if TLISettingsFontPickerViewController.selectedKey() == "TimesNewRoman" {
                listLabel.font = UIFont.preferredTimesNewRomanFontForTextStyle(UIFontTextStyleBody)
                totalTasksLabel.font = UIFont.preferredTimesNewRomanFontForTextStyle(UIFontTextStyleBody)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Palatino" {
                listLabel.font = UIFont.preferredPalatinoFontForTextStyle(UIFontTextStyleBody)
                totalTasksLabel.font = UIFont.preferredPalatinoFontForTextStyle(UIFontTextStyleBody)
            } else if TLISettingsFontPickerViewController.selectedKey() == "Iowan" {
                listLabel.font = UIFont.preferredIowanFontForTextStyle(UIFontTextStyleBody)
                totalTasksLabel.font = UIFont.preferredIowanFontForTextStyle(UIFontTextStyleBody)
            }
        } else {
            let fontSize:Float = userDefaults.floatForKey("kFontSize")
            listLabel.font = UIFont.tinylogFontOfSize(CGFloat(fontSize))
            totalTasksLabel.font = UIFont.tinylogFontOfSize(CGFloat(fontSize - 2))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size:CGSize = self.contentView.bounds.size
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
        listLabel.preferredMaxLayoutWidth = CGRectGetWidth(listLabel.frame)
        
        if self.editing {
            bgView?.width = size.width + 78.0
            bgView?.height = size.height
        } else {
            bgView?.width = size.width
            bgView?.height = size.height
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

