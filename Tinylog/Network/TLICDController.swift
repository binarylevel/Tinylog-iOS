//
//  TLICDController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 16/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

class TLICDController: NSObject {
    var coordinator:NSPersistentStoreCoordinator?
    var store:NSPersistentStore?
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Tinylog", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
          try coordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storeURL, options: [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true])
            
        } catch {
            fatalError("Could not add the persistent store: \(error).")
        }
        
        return coordinator
    }()
    
    lazy var parentContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var context: NSManagedObjectContext? = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.parentContext
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }()
    
    // MARK: Singleton
    class var sharedInstance : TLICDController {
        struct Static {
            static var onceToken:dispatch_once_t = 0
            static var instance:TLICDController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = TLICDController()
        }
        return Static.instance!
    }
    
    override init() {
        super.init()
    }
    
    func saveContext() {
        if (context?.hasChanges != nil) {
            
            do {
                try context?.save()
            } catch {
                //print("falied to save context")
            }
        } else {
            //print("skipped context save there are no changes")
        }
    }
    
    func backgroundSaveContext() {
        
        saveContext()
        
        parentContext?.performBlock({ () -> Void in
            if (self.parentContext?.hasChanges != nil) {
                do {
                    try self.parentContext?.save()
                } catch {
                    //print("falied to save parentContext")
                }
            } else {
                //print("skipped parentContext save there are no changes")
            }
        })
    }
    
    lazy var storeDirectoryURL:NSURL? = {
        do {
            let directoryURL = try NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
            let pathComponent = NSBundle.mainBundle().bundleIdentifier
            directoryURL.URLByAppendingPathComponent(pathComponent!, isDirectory: true)
            return directoryURL
        } catch {
            fatalError("Error occured: \(error).")
        }
         return nil
    }()
    
    lazy var storeURL:NSURL? = {
        let storeURL = self.storeDirectoryURL?.URLByAppendingPathComponent("store.sqlite")
        return storeURL
    }()
}
