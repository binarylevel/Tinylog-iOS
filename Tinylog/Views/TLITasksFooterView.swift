//
//  TLITasksFooterView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TLITasksFooterView: UIView {
    
    var borderLineView:UIView = {
        let borderLineView = UIView.newAutoLayoutView()
        borderLineView.backgroundColor = UIColor(red: 213.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
        return borderLineView
    }()

    let footerView:UIView = UIView.newAutoLayoutView()
    
    var infoLabel:TTTAttributedLabel? = {
        let infoLabel = TTTAttributedLabel.newAutoLayoutView()
        infoLabel.font = UIFont.regularFontWithSize(14.0)
        infoLabel.textColor = UIColor.tinylogTextColor()
        infoLabel.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        infoLabel.text = ""
        return infoLabel
    }()
    
    var currentText:String?
    var didSetupContraints = false
    
    lazy var exportTasksButton:TLIExportTasksButton? = {
        let exportTasksButton = TLIExportTasksButton.newAutoLayoutView()
        return exportTasksButton
    }()
    
    lazy var archiveButton:TLIArchiveButton? = {
        let archiveButton = TLIArchiveButton.newAutoLayoutView()
        return archiveButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        footerView.backgroundColor = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        addSubview(footerView)
        
        addSubview(borderLineView)
        addSubview(infoLabel!)
        
        addSubview(exportTasksButton!)
        addSubview(archiveButton!)
        
        updateInfoLabel("")
        
        setNeedsUpdateConstraints()
    }
    
    func updateInfoLabel(str:String) {
        currentText = str
        infoLabel?.text = str
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
            
            exportTasksButton?.autoSetDimensionsToSize(CGSize(width: 21.0, height: 28.0))
            exportTasksButton?.autoAlignAxisToSuperviewAxis(.Horizontal)
            exportTasksButton?.autoPinEdgeToSuperviewEdge(.Left, withInset: smallPadding)
            
            archiveButton?.autoSetDimensionsToSize(CGSize(width: 28.0, height: 26.0))
            archiveButton?.autoAlignAxisToSuperviewAxis(.Horizontal)
            archiveButton?.autoPinEdgeToSuperviewEdge(.Right, withInset: smallPadding)
            
            infoLabel?.autoCenterInSuperview()
            
            didSetupContraints = true
        }
        super.updateConstraints()
    }
}

