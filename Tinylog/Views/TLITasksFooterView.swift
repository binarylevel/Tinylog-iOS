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
    
    var borderLineView:UIView?
    let footerView:UIView = UIView()
    var infoLabel:TTTAttributedLabel?
    var currentText:String?
    
    lazy var exportTasksButton:TLIExportTasksButton? = {
        let exportTasksButton = TLIExportTasksButton()
        return exportTasksButton
        }()
    
    lazy var archiveButton:TLIArchiveButton? = {
        let archiveButton = TLIArchiveButton()
        return archiveButton
        }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        footerView.backgroundColor = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        self.addSubview(footerView)
        
        borderLineView = UIView(frame: CGRectMake(0.0, 0.0, self.frame.size.width, 0.5))
        borderLineView?.backgroundColor = UIColor(red: 213.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
        self.addSubview(borderLineView!)
        
        infoLabel = TTTAttributedLabel(frame: CGRectMake(0.0, 0.0, self.frame.size.width, 51.0))
        infoLabel?.font = UIFont.regularFontWithSize(14.0)
        infoLabel?.textColor = UIColor.tinylogTextColor()
        infoLabel?.verticalAlignment = TTTAttributedLabelVerticalAlignment.Top
        self.addSubview(infoLabel!)
        
        self.addSubview(self.exportTasksButton!)
        self.addSubview(self.archiveButton!)
    }
    
    func updateInfoLabel(str:String) {
        currentText = str
        infoLabel?.text = str
        let size:CGSize = self.frame.size
        let infoLabelText:NSString = infoLabel!.text!
        let rect:CGRect = infoLabelText.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.regularFontWithSize(14.0)], context: nil)
        
        var infoLabelFrame:CGRect = infoLabel!.frame
        infoLabelFrame.size.height = rect.size.height
        infoLabelFrame.origin.x = round(self.frame.size.width / 2.0 - rect.size.width / 2.0)
        infoLabelFrame.origin.y = round(51.0 / 2.0 - rect.size.height / 2.0)
        infoLabel?.frame = infoLabelFrame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        footerView.frame = self.bounds
        borderLineView!.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 0.5)
        exportTasksButton!.frame = CGRectMake(17.0, round(self.frame.size.height / 2.0 - 30.0 / 2.0), 21.0, 28.0)
        archiveButton!.frame = CGRectMake(self.frame.size.width - 39.0, round(self.frame.size.height / 2.0 - 26.0 / 2.0), 28.0, 26.0)
        if let text = currentText {
            updateInfoLabel(text)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

