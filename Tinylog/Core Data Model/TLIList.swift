//
//  TLIList.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation
import CoreData

class TLIList: NSManagedObject {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        if self.uniqueIdentifier == nil {
            self.uniqueIdentifier = NSProcessInfo.processInfo().globallyUniqueString
        }
    }
    
    func highestPosition()->NSInteger {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        fetchRequest.predicate = NSPredicate(format: "list = %@", self)
        fetchRequest.sortDescriptors = [positionDescriptor]
        fetchRequest.fetchLimit = 1
        
        do {
            let results:NSArray = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
            
            if results.count == 0 {
                return 0
            }
            let task:TLITask = results.objectAtIndex(0) as! TLITask
            return task.list!.position!.integerValue
        } catch let error as NSError {
            print("error : \(error.localizedDescription)")
        }
        return 0
    }
    
    func numberOfLists()->NSInteger {
        //Fetch all objects from list
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequestTotal:NSFetchRequest = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        fetchRequestTotal.sortDescriptors = [positionDescriptor]
        fetchRequestTotal.predicate  = NSPredicate(format: "archivedAt = nil AND list = %@", self)
        fetchRequestTotal.fetchBatchSize = 20
        
        do {
            let results:NSArray = try cdc.context!.executeFetchRequest(fetchRequestTotal)
            return results.count
        } catch let error as NSError {
            print("error : \(error.localizedDescription)")
        }
        return 0
    }

}
