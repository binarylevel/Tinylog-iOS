//
//  TLIListsFooterView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TLIListsFooterView: UIView {
    
    var infoLabel:TTTAttributedLabel? = {
        let infoLabel = TTTAttributedLabel.newAutoLayoutView()
        infoLabel.font = UIFont.regularFontWithSize(14.0)
        infoLabel.textColor = UIColor.tinylogTextColor()
        infoLabel.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        infoLabel.text = "Lorem ipsum dolor sit amet"
        return infoLabel
    }()
    
    var borderLineView:UIView = {
        let borderLineView = UIView.newAutoLayoutView()
        borderLineView.backgroundColor = UIColor(red: 213.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
        return borderLineView
    }()
    
    var currentText:String?
    let footerView:UIView = UIView.newAutoLayoutView()
    var didSetupContraints = false
    
    lazy var addListButton:TLIAddListButton? = {
        let addListButton = TLIAddListButton.newAutoLayoutView()
        return addListButton
    }()
    
    lazy var archiveButton:TLIArchiveButton? = {
        let archiveButton = TLIArchiveButton.newAutoLayoutView()
        return archiveButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        footerView.backgroundColor = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        self.addSubview(footerView)
        
        self.addSubview(borderLineView)
        self.addSubview(infoLabel!)
        self.addSubview(addListButton!)
        self.addSubview(archiveButton!)
        
        updateInfoLabel("")
        
        setNeedsUpdateConstraints()
    }
    
    func updateInfoLabel(str:String) {
        currentText = str
        infoLabel?.text = str
        
        setNeedsUpdateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func updateConstraints() {
        
        let smallPadding:CGFloat = 16.0
        
        if !didSetupContraints {
        
            footerView.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
            footerView.autoSetDimension(.Height, toSize: 51.0)
            footerView.autoPinEdgeToSuperviewEdge(.Bottom)
            
            borderLineView.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
            borderLineView.autoSetDimension(.Height, toSize: 0.5)
            borderLineView.autoPinEdgeToSuperviewEdge(.Top)
            
            addListButton?.autoSetDimensionsToSize(CGSize(width: 18.0, height: 18.0))
            addListButton?.autoAlignAxisToSuperviewAxis(.Horizontal)
            addListButton?.autoPinEdgeToSuperviewEdge(.Left, withInset: smallPadding)
            
            archiveButton?.autoSetDimensionsToSize(CGSize(width: 28.0, height: 26.0))
            archiveButton?.autoAlignAxisToSuperviewAxis(.Horizontal)
            archiveButton?.autoPinEdgeToSuperviewEdge(.Right, withInset: smallPadding)
            
            infoLabel?.autoCenterInSuperview()
            
            didSetupContraints = true
        }
        super.updateConstraints()
    }
}

