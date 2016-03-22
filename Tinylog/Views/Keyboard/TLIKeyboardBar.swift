//
//  TLIKeyboardBar.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIKeyboardBar: UIView, UIInputViewAudioFeedback {
    
    var keyInputView:UIKeyInput?
    let buttonHashTag:UIButton = UIButton()
    let buttonMention:UIButton = UIButton()
    
    var enableInputClicksWhenVisible: Bool {
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.backgroundColor = UIColor.tinylogNavigationBarDayColor()
        
        buttonHashTag.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 20.0)
        buttonHashTag.setTitleColor(UIColor.tinylogMainColor(), forState: UIControlState.Normal)
        buttonHashTag.setTitle("#", forState: UIControlState.Normal)
        buttonHashTag.addTarget(self, action: #selector(TLIKeyboardBar.buttonHashTagPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(buttonHashTag)
        
        buttonMention.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 20.0)
        buttonMention.setTitleColor(UIColor.tinylogMainColor(), forState: UIControlState.Normal)
        buttonMention.setTitle("@", forState: UIControlState.Normal)
        buttonMention.addTarget(self, action: #selector(TLIKeyboardBar.buttonMentionPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(buttonMention)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buttonHashTag.frame = CGRectMake(20.0, 1.0, 20.0, self.bounds.size.height - 1.0)
        buttonMention.frame = CGRectMake(60.0, 1.0, 20.0, self.bounds.size.height - 1.0)
    }
    
    func buttonHashTagPressed(button:UIButton) {
        UIDevice.currentDevice().playInputClick()
        keyInputView?.insertText("#")
    }
    
    func buttonMentionPressed(button:UIButton) {
        UIDevice.currentDevice().playInputClick()
        keyInputView?.insertText("@")
    }
}

