//
//  TLIHelpTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import SGBackgroundView

class TLIHelpTableViewCell: TLITableViewCell {
    
    var didSetupConstraints = false
    var bgView:SGBackgroundView?
    let helpLabel:TTTAttributedLabel = TTTAttributedLabel.newAutoLayoutView()
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bgView = SGBackgroundView(frame: CGRectZero)
        bgView?.bgColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        bgView?.lineColor = UIColor(red: 213.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
        bgView?.xPosLine = 16.0
        self.backgroundView = bgView!
        
        helpLabel.lineBreakMode = .ByTruncatingTail
        helpLabel.numberOfLines = 0
        helpLabel.textAlignment = .Left
        helpLabel.textColor = UIColor.tinylogTextColor()
        self.contentView.addSubview(helpLabel)
        
        let selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView.backgroundColor = UIColor(red: 237.0 / 255.0, green: 237.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
        selectedBackgroundView.contentMode = UIViewContentMode.Redraw
        self.selectedBackgroundView = selectedBackgroundView
        
        updateFonts()
        
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            
            helpLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 20.0)
            helpLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: 16.0)
            helpLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 16.0)
            helpLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 20.0)
            
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
                helpLabel.font = UIFont.preferredAvenirFontForTextStyle(UIFontTextStyleBody)
            } else if TLISettingsFontPickerViewController.selectedKey() == "HelveticaNeue" {
                helpLabel.font = UIFont.preferredHelveticaNeueFontForTextStyle(UIFontTextStyleBody)
            }
        } else {
            let fontSize:Float = userDefaults.floatForKey("kFontSize")
            helpLabel.font = UIFont.tinylogFontOfSize(CGFloat(fontSize))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size:CGSize = self.contentView.bounds.size
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
        helpLabel.preferredMaxLayoutWidth = CGRectGetWidth(helpLabel.frame)
        
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

