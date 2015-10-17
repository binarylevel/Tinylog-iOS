//
//  TLITask.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation
import CoreData

class TLITask: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        if self.uniqueIdentifier == nil {
            self.uniqueIdentifier = NSProcessInfo.processInfo().globallyUniqueString
        }
    }
}
