//
//  TLITag.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation
import CoreData

class TLITag: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        if self.uniqueIdentifier == nil {
            self.uniqueIdentifier = NSProcessInfo.processInfo().globallyUniqueString
        }
    }
    
    class func existing(name:NSString, context:NSManagedObjectContext)->TLITag? {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Tag")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result:NSArray = try context.executeFetchRequest(fetchRequest)
            
            if (result.lastObject != nil) {
                return result.lastObject as? TLITag
            } else {
                let tag:TLITag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: context) as! TLITag
                tag.name = name as String
                return tag
            }
        } catch let error as NSError {
            print("error : \(error.localizedDescription)")
            return nil
        }
    }

}
