//
//  TLIAppDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 16/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import Reachability
import SGReachability
import FBSDKCoreKit
import Mixpanel
import Fabric
import Crashlytics


@UIApplicationMain
class TLIAppDelegate: UIResponder, UIApplicationDelegate {
    
    enum ShortcutIdentifier: String {
        case CreateNewList
        
        init?(fullIdentifier: String) {
            guard let shortIdentifier = fullIdentifier.componentsSeparatedByString(".").last else {
                return nil
            }
            self.init(rawValue: shortIdentifier)
        }
    }

    var window: UIWindow?
    var networkMode:String?
    
    class func sharedAppDelegate()->TLIAppDelegate {
        return UIApplication.sharedApplication().delegate as! TLIAppDelegate
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem,
        completionHandler: (Bool) -> Void) {
            
            completionHandler(handleShortcut(shortcutItem))
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if #available(iOS 9.0, *) {
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
                print(shortcutItem)
                handleShortcut(shortcutItem)
                return false
            }
        } else {
            print("quick actions not supported")
        }
        
        //Register defaults
        let standardDefaults = NSUserDefaults.standardUserDefaults()
        standardDefaults.registerDefaults([
            String(kTLIFontDefaultsKey): kTLIFontHelveticaNeueKey,
            String(TLIUserDefaults.kTLISyncMode): "off",
            "kFontSize": 17.0,
            "kSystemFontSize": "off",
            "kSetupScreen": "on"])
        
        do {
           
            try NSFileManager.defaultManager().createDirectoryAtURL(TLICDController.sharedInstance.storeDirectoryURL!, withIntermediateDirectories: true, attributes: nil)
          
        } catch { 
            fatalError("Cannot create directory \(error)")
        }
        
        let syncManager:TLISyncManager = TLISyncManager.sharedSyncManager()
        syncManager.managedObjectContext = TLICDController.sharedInstance.context
        syncManager.storePath = TLICDController.sharedInstance.storeURL?.path
        syncManager.setup()
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: TLICDController.sharedInstance.context, queue: nil) { (note) -> Void in
            syncManager.synchronizeWithCompletion(nil)
        }
        
        Crashlytics.startWithAPIKey("88300c2a59d5352c19153a01c6671ab3339d663e")
        Mixpanel.sharedInstanceWithToken(kMixpanelToken)
        SGReachabilityController.sharedController()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
        
        if  IS_IPAD {
            self.window?.rootViewController = TLISplitViewController()
            TLIAnalyticsTracker.trackMixpanelEvent("Open App", properties: ["device": "ipad"])
        } else {
            let listsViewController:TLIListsViewController = TLIListsViewController()
            let navigationController:UINavigationController = UINavigationController(rootViewController: listsViewController);
            self.window!.rootViewController = navigationController;
            TLIAnalyticsTracker.trackMixpanelEvent("Open App", properties: ["device": "iphone"])
        }
        
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.makeKeyAndVisible()
        
        //Change color cursor for UITextField
        UITextField.appearance().tintColor = UIColor.tinylogMainColor()
        
        //Check for reachability
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityDidChange:", name: kReachabilityChangedNotification, object: nil)
        
        let navigationBar:UINavigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = UIColor.tinylogNavigationBarDayColor()
        navigationBar.tintColor = UIColor.tinylogMainColor()
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont.mediumFontWithSize(18.0), NSForegroundColorAttributeName : UIColor.tinylogTextColor()]
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        
        //Register for custom notifications
        let notificationActionOk :UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationActionOk.identifier = "COMPLETE_IDENTIFIER"
        notificationActionOk.title = "Complete"
        notificationActionOk.destructive = false
        notificationActionOk.authenticationRequired = true
        notificationActionOk.activationMode = UIUserNotificationActivationMode.Background
        
        let notificationActionCancel :UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        notificationActionCancel.identifier = "NOT_NOW_IDENTIFIER"
        notificationActionCancel.title = "Not Now"
        notificationActionCancel.destructive = false
        notificationActionCancel.authenticationRequired = true
        notificationActionCancel.activationMode = UIUserNotificationActivationMode.Background
        
        let notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        notificationCategory.identifier = "TASK_CATEGORY"
        notificationCategory .setActions([notificationActionOk,notificationActionCancel], forContext: UIUserNotificationActionContext.Default)
        notificationCategory .setActions([notificationActionOk,notificationActionCancel], forContext: UIUserNotificationActionContext.Minimal)
        
        let categories = Set<UIUserNotificationCategory>(arrayLiteral: notificationCategory)
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories)
        application.registerUserNotificationSettings(settings)
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        //check for local nots
        let app:UIApplication = UIApplication.sharedApplication()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let displaySetupScreen:NSString = userDefaults.objectForKey("kSetupScreen") as! NSString
        
        if displaySetupScreen == "on" {
            app.cancelAllLocalNotifications()
            
            //Setup Mixpanel
            TLIAnalyticsTracker.createAlias(Mixpanel.sharedInstance().distinctId)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidEndNotification:", name: IDMSyncActivityDidEndNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidBeginNotification:", name: IDMSyncActivityDidBeginNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearPassedNotifications", name: "TLIClearPassedNotifications", object: nil)
        
        if #available(iOS 8.2, *) {
            let fontMedium = UIFont.systemFontOfSize(18, weight: UIFontWeightBlack)
             print(fontMedium)
        } else {
            // Fallback on earlier versions
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func syncLocalNotifications() {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Notification")
        let positionDescriptor  = NSSortDescriptor(key: "uniqueIdentifier", ascending: false)
        fetchRequest.sortDescriptors = [positionDescriptor]
        
        do {
            let results:NSArray = try cdc.context!.executeFetchRequest(fetchRequest)
            
            for var j:Int = 0; j < results.count; j++ {
                let notification:TLINotification = results.objectAtIndex(j) as! TLINotification
                
                if notification.fireDate!.timeIntervalSinceNow < 0.0 {
                    //time has passed
                } else {
                    //Match the notification here if exists cancel it.
                    let app:UIApplication = UIApplication.sharedApplication()
                    let notifications:NSArray = app.scheduledLocalNotifications!
                    
                    for tmpNotification in notifications {
                        let temp:UILocalNotification = tmpNotification as! UILocalNotification
                        
                        if let userInfo:NSDictionary = temp.userInfo {
                       
                            let uniqueIdentifier: String? = userInfo.valueForKey("uniqueIdentifier") as? String
                            
                            if notification.updatedAt != nil {
                                
                                if uniqueIdentifier == notification.uniqueIdentifier {
                                    app.cancelLocalNotification(temp)
                                }
                            }
                        }
                    }
                    createLocalNotification(notification)
                }
            }
        } catch let error as NSError {
            print("\(error)")
        }
    }
    
    func syncActivityDidEndNotification(notification:NSNotification) {
        syncLocalNotifications()
    }
    
    func syncActivityDidBeginNotification(notification:NSNotification) {
    }

    func reachabilityDidChange(notification:NSNotification) {
        let reachability:Reachability = notification.object as! Reachability
        
        if reachability.isReachable() {
            if reachability.isReachableViaWiFi() {
                networkMode = "wifi"
            } else if reachability.isReachableViaWWAN() {
                networkMode = "wwan"
            }
        } else {
            networkMode = "notReachable"
        }
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
        
        var identifier:UIBackgroundTaskIdentifier = 0
        identifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
        })
        dispatch_async(dispatch_get_main_queue()) {
            TLICDController.sharedInstance.backgroundSaveContext()
            TLISyncManager.sharedSyncManager().synchronizeWithCompletion({ (error) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(identifier)
            })
            
        }

//        dispatch_async(dispatch_get_global_queue(0, 0)) {
//            TLICDController.sharedInstance.backgroundSaveContext()
//            TLISyncManager.sharedSyncManager().synchronizeWithCompletion({ (error) -> Void in
//                UIApplication.sharedApplication().endBackgroundTask(identifier)
//            })
        //}
        UIApplication.sharedApplication().applicationIconBadgeNumber =  0
        Mixpanel.sharedInstance().flush()
    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        TLISyncManager.sharedSyncManager().synchronizeWithCompletion(nil)
        UIApplication.sharedApplication().applicationIconBadgeNumber =  0
    }

    func applicationWillTerminate(application: UIApplication) {
        TLICDController.sharedInstance.backgroundSaveContext()
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if application.applicationState == UIApplicationState.Inactive {}
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        let syncManager:TLISyncManager = TLISyncManager.sharedSyncManager()
        if syncManager.canSynchronize() {
            syncManager.synchronizeWithCompletion { (error) -> Void in
                if error != nil {
                    completionHandler(UIBackgroundFetchResult.Failed)
                    if error.code == 1003 {}
                } else {
                    completionHandler(UIBackgroundFetchResult.NewData)
                }
            }
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        if let identifier = identifier {
            if notification.category == "TASK_CATEGORY" {
                if identifier == "COMPLETE_IDENTIFIER" {
                    if let userInfo:NSDictionary = notification.userInfo {
                        let displayText: String? = userInfo.valueForKey("displayText") as? String
               
                        let cdc:TLICDController = TLICDController.sharedInstance
                        
                        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Task")
                        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
                        fetchRequest.predicate = NSPredicate(format: "displayLongText = %@", displayText!)
                        fetchRequest.sortDescriptors = [positionDescriptor]
                        fetchRequest.fetchLimit = 1
                        
                        do {
                            let results:NSArray = try cdc.context!.executeFetchRequest(fetchRequest)
                            let task:TLITask = results.objectAtIndex(0) as! TLITask
                            
                            if !task.completed!.boolValue {
                                task.completed = NSNumber(bool: true)
                                task.checkBoxValue = "true"
                                task.completedAt = NSDate()
                            }
                            
                            task.updatedAt = NSDate()
                            cdc.backgroundSaveContext()
                        } catch let error as NSError {
                            print("\(error.localizedDescription)")
                        }

                    }
                }
            }
        }
        completionHandler()
    }
    
    func clearPassedNotifications() {
        
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Notification")
        let positionDescriptor  = NSSortDescriptor(key: "uniqueIdentifier", ascending: false)
        fetchRequest.sortDescriptors = [positionDescriptor]
        
        do {
            let results:NSArray = try cdc.context!.executeFetchRequest(fetchRequest)
            
            for item in  results {
                let notification:TLINotification = item as! TLINotification
                if notification.fireDate!.timeIntervalSinceNow < 0.0 {
                    cdc.context?.deleteObject(notification)
                }
            }
            
            cdc.backgroundSaveContext()
            
        } catch let error as NSError {
            print("clearPassedNotifications with error \(error.localizedDescription)")
        }
    }
    
    func createLocalNotification(notification:TLINotification) {
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertBody = notification.displayText
        localNotification.soundName = "beep-xylo.aif";
        localNotification.fireDate = notification.fireDate
        localNotification.category = "TASK_CATEGORY"
        
        var userInfo = [String:String]()
        let uniqueIdentifier = notification.uniqueIdentifier
        let displayText = notification.displayText
        
        userInfo["uniqueIdentifier"] = uniqueIdentifier
        userInfo["displayText"] = displayText
        
        localNotification.userInfo = userInfo
        localNotification.applicationIconBadgeNumber++;
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        TLIAnalyticsTracker.trackMixpanelEvent("", properties: [
            "uniqueIdentifier": uniqueIdentifier!,
            "displayText": displayText!])
    }
    
    @available(iOS 9.0, *)
    func handleShortcut(shortcutItem:UIApplicationShortcutItem)->Bool {
        let shortcutType = shortcutItem.type
        print(shortcutType)
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }
        
        return selectTabBarItemForIdentifier(shortcutIdentifier)
    }
    
    private func selectTabBarItemForIdentifier(identifier: ShortcutIdentifier) -> Bool {
    
        switch (identifier) {
        case .CreateNewList:
            print("create new list")
            if let navigationController = window?.rootViewController as? UINavigationController {
                if let vc = navigationController.viewControllers[0] as? TLIListsViewController {
                    vc.addNewList(nil)
                }
            }

            return true
        }
    }
}

