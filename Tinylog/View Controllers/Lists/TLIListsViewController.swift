//
//  TLIListsViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIListsViewController: TLICoreDataTableViewController {
    
    func configureFetch() {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt = nil")
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cdc.context!, sectionNameKeyPath: nil, cacheName: nil)
        self.frc?.delegate = self
        
        do {
            try self.frc?.performFetch()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFetch()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidEndNotification:", name: IDMSyncActivityDidEndNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidBeginNotification:", name: IDMSyncActivityDidBeginNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFonts", name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "onChangeSize:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        self.delay(5) { () -> () in
            //test mode
            let syncManager = TLISyncManager.sharedSyncManager()
            
            syncManager.connectToSyncService(IDMICloudService) { (error) -> Void in
                print("connect")
                if error != nil {
                    if error.code == 1003 {
                        print("error")
                    }
                } else {
                    print("connected")
                }
            }
        }
        
  
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func syncActivityDidBeginNotification(notification:NSNotification) {
        if TLISyncManager.sharedSyncManager().canSynchronize() {
            print("sync")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            if TLIAppDelegate.sharedAppDelegate().networkMode == "notReachable" {
                //listsFooterView?.updateInfoLabel("Offline")
            } else {
                //listsFooterView?.updateInfoLabel("Syncing...")
            }
        }
    }
    
    func syncActivityDidEndNotification(notification:NSNotification) {
        if TLISyncManager.sharedSyncManager().canSynchronize() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.formatterBehavior = NSDateFormatterBehavior.Behavior10_4
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            
            //check for connectivity
            if TLIAppDelegate.sharedAppDelegate().networkMode == "notReachable" {
                //listsFooterView?.updateInfoLabel("Offline")
            } else {
                //listsFooterView?.updateInfoLabel(NSString(format: "Last Updated %@", dateFormatter.stringForObjectValue(NSDate())!) as String)
            }
            //checkForLists()
            
            let cdc:TLICDController = TLICDController.sharedInstance
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "List")
            let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
            let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
            fetchRequest.predicate = NSPredicate(format: "archivedAt = nil")
            
            do {
                let results = try cdc.context?.executeFetchRequest(fetchRequest)
                print(results?.count)
                
                for item in results! {
                    let list = item as! TLIList
                    print(list.title)
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
           
        }
    }
    
}
