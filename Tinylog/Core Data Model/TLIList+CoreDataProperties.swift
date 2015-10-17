//
//  TLIList+CoreDataProperties.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TLIList {

    @NSManaged var archivedAt: NSDate?
    @NSManaged var color: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var position: NSNumber?
    @NSManaged var title: String?
    @NSManaged var total: NSNumber?
    @NSManaged var uniqueIdentifier: String?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var tasks: NSSet?

}
