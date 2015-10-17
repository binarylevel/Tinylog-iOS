//
//  TLITask+CoreDataProperties.swift
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

extension TLITask {

    @NSManaged var archivedAt: NSDate?
    @NSManaged var checkBoxValue: String?
    @NSManaged var completed: NSNumber?
    @NSManaged var completedAt: NSDate?
    @NSManaged var createdAt: NSDate?
    @NSManaged var displayLongText: String?
    @NSManaged var position: NSNumber?
    @NSManaged var reminder: NSDate?
    @NSManaged var uniqueIdentifier: String?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var list: TLIList?
    @NSManaged var mentions: NSSet?
    @NSManaged var notification: TLINotification?
    @NSManaged var tags: NSSet?

}
