//
//  TLIMention.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation
import CoreData

class TLIMention: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        if self.uniqueIdentifier == nil {
            self.uniqueIdentifier = NSProcessInfo.processInfo().globallyUniqueString
        }
    }
    
    class func existing(name:NSString, context:NSManagedObjectContext)->TLIMention? {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Mention")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result:NSArray = try context.executeFetchRequest(fetchRequest)
            
            if (result.lastObject != nil) {
                return result.lastObject as? TLIMention
            } else {
                let mention:TLIMention = NSEntityDescription.insertNewObjectForEntityForName("Mention", inManagedObjectContext: context) as! TLIMention
                mention.name = name as String
                return mention
            }
        } catch let error as NSError {
            print("error : \(error.localizedDescription)")
          return nil
        }
    }
}
