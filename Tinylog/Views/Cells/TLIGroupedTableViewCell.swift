//
//  TLIGroupedTableViewCell.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIGroupedTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.whiteColor()
        self.textLabel!.font = UIFont.tinylogInterfaceFontOfSize(17.0)!
        self.textLabel!.textColor = UIColor.tinylogTextColor()
        self.detailTextLabel?.font = UIFont.tinylogInterfaceFontOfSize(17.0)!
        self.detailTextLabel?.textColor = UIColor.tinylogTextColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
