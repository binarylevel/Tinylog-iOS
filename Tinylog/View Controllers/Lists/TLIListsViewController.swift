//
//  TLIListsViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import CoreData

class TLIListsViewController: TLICoreDataTableViewController, UITextFieldDelegate, TLIAddListViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    struct RestorationKeys {
        static let viewControllerTitle = "ViewControllerTitleKey"
        static let searchControllerIsActive = "SearchControllerIsActiveKey"
        static let searchBarText = "SearchBarTextKey"
        static let searchBarIsFirstResponder = "SearchBarIsFirstResponderKey"
    }
    
    // State restoration values.
    struct SearchControllerRestorableState {
        var wasActive = false
        var wasFirstResponder = false
    }
    
    var restoredState = SearchControllerRestorableState()
    
    let kEstimateRowHeight = 61
    let kCellIdentifier = "CellIdentifier"
    var editingIndexPath:NSIndexPath?
    var estimatedRowHeightCache:NSMutableDictionary?
    var resultsTableViewController:TLIResultsTableViewController?
    var searchController:UISearchController?
    var topBarView:UIView?
    var didSetupContraints = false
    
    var listsFooterView:TLIListsFooterView? = {
        let listsFooterView = TLIListsFooterView.newAutoLayoutView()
        return listsFooterView
    }()

    lazy var noListsLabel:UILabel? = {
        let noListsLabel:UILabel = UILabel.newAutoLayoutView()
        noListsLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
        noListsLabel.textColor = UIColor.tinylogTextColor()
        noListsLabel.textAlignment = NSTextAlignment.Center
        noListsLabel.text = "Tap + icon to create a new list."
        return noListsLabel
    }()
    
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
            fatalError(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFetch()
        
        self.title = "My Lists"
        
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        
        self.tableView?.translatesAutoresizingMaskIntoConstraints = false
        self.tableView?.backgroundView = UIView()
        self.tableView?.backgroundView?.backgroundColor = UIColor.clearColor()
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        //self.tableView?.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 50.0)
        
        self.tableView?.registerClass(TLIListTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 61
        
        resultsTableViewController = TLIResultsTableViewController()
        resultsTableViewController?.tableView?.delegate = self
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        searchController?.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchController?.searchBar.setSearchFieldBackgroundImage(UIImage(named: "search-bar-bg-gray"), forState: UIControlState.Normal)
        
        searchController?.searchBar.tintColor = UIColor.tinylogMainColor()
        
        let searchField:UITextField = searchController?.searchBar.valueForKey("searchField") as! UITextField
        searchField.textColor = UIColor.tinylogTextColor()
        
        self.tableView?.tableHeaderView = searchController?.searchBar
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.searchBar.delegate = self
        
        let settingsImage:UIImage = UIImage(named: "740-gear-toolbar")!
        let settingsButton:UIButton = UIButton(type: UIButtonType.Custom)
        settingsButton.frame = CGRectMake(0, 0, 22, 22);
        settingsButton.setBackgroundImage(settingsImage, forState: UIControlState.Normal)
        settingsButton.setBackgroundImage(settingsImage, forState: UIControlState.Highlighted)
        settingsButton.addTarget(self, action: "displaySettings:", forControlEvents: UIControlEvents.TouchDown)
        
        let settingsBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: settingsButton)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = settingsBarButtonItem
        
        listsFooterView?.addListButton?.addTarget(self, action: "addNewList:", forControlEvents: UIControlEvents.TouchDown)
        listsFooterView?.archiveButton?.addTarget(self, action: "displayArchive:", forControlEvents: UIControlEvents.TouchDown)
        
        setEditing(false, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidEndNotification:", name: IDMSyncActivityDidEndNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidBeginNotification:", name: IDMSyncActivityDidBeginNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFonts", name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onChangeSize:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        definesPresentationContext = true
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(noListsLabel!)
        view.addSubview(listsFooterView!)
        view.setNeedsUpdateConstraints()
    }
    
    func deleteMentionWithName(name:String) {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Mention")
        let nameDescriptor  = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate  = NSPredicate(format: "name = %@", name)
        fetchRequest.sortDescriptors = [nameDescriptor]
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchBatchSize = 20
        
        do {
            let mentions:NSArray = try cdc.context!.executeFetchRequest(fetchRequest)
            let mention:TLIMention = mentions.lastObject as! TLIMention
            cdc.context?.deleteObject(mention)
            cdc.backgroundSaveContext()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func viewAllMentions() {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Mention")
        let displayLongTextDescriptor  = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [displayLongTextDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        do {
            let mentions:NSArray = try cdc.context!.executeFetchRequest(fetchRequest)
            
            for item in mentions {
                let mention:TLIMention = item as! TLIMention
                print("mention.name \(mention.name)")
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteTagWithName(name:String) {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Tag")
        let nameDescriptor  = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate  = NSPredicate(format: "name = %@", name)
        fetchRequest.sortDescriptors = [nameDescriptor]
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchBatchSize = 20
        
        do {
            let tags:NSArray = try  cdc.context!.executeFetchRequest(fetchRequest)
            let tag:TLITag = tags.lastObject as! TLITag
            cdc.context?.deleteObject(tag)
            cdc.backgroundSaveContext()
        } catch let error  as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func viewAllTags() {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Tag")
        let displayLongTextDescriptor  = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [displayLongTextDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        do {
            let tags:NSArray = try cdc.context!.executeFetchRequest(fetchRequest)
            
            for item in tags {
                let tag:TLITag = item as! TLITag
                print("tag.name \(tag.name)")
            }
        } catch let error  as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func onChangeSize(notification:NSNotification) {
        self.tableView?.reloadData()
    }
    
    func checkForLists() {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt = nil")
        
        do {
            let results = try cdc.context?.executeFetchRequest(fetchRequest)
            
            if results?.count == 0 {
                self.noListsLabel?.hidden = false
            } else {
                self.noListsLabel?.hidden = true
            }
        } catch let error  as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    override func updateViewConstraints() {
        
        if !didSetupContraints {
            
            tableView?.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            tableView?.autoMatchDimension(.Height, toDimension: .Height, ofView: self.view, withOffset: -50.0)
            
            noListsLabel?.autoCenterInSuperview()
            
            listsFooterView?.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            listsFooterView?.autoSetDimension(.Height, toSize: 51.0)
            listsFooterView?.autoPinEdgeToSuperviewEdge(.Left)
            listsFooterView?.autoPinEdgeToSuperviewEdge(.Bottom)
            
            didSetupContraints = true
        }
        super.updateViewConstraints()
    }
    
    func appBecomeActive() {
        startSync()
    }
    
    func startSync() {
        let syncManager:TLISyncManager = TLISyncManager.sharedSyncManager()
        if syncManager.canSynchronize() {
            syncManager.synchronizeWithCompletion { (error) -> Void in
            }
        }
    }
    
    func updateFonts() {
        self.tableView?.reloadData()
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
                listsFooterView?.updateInfoLabel("Offline")
            } else {
                listsFooterView?.updateInfoLabel(NSString(format: "Last Updated %@", dateFormatter.stringForObjectValue(NSDate())!) as String)
            }
            checkForLists()
        }
    }
    
    func syncActivityDidBeginNotification(notification:NSNotification) {
        if TLISyncManager.sharedSyncManager().canSynchronize() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            if TLIAppDelegate.sharedAppDelegate().networkMode == "notReachable" {
                listsFooterView?.updateInfoLabel("Offline")
            } else {
                listsFooterView?.updateInfoLabel("Syncing...")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
            // Code here will execute before the rotation begins.
            // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
            coordinator.animateAlongsideTransition({ (context) -> Void in
                // Place code here to perform animations during the rotation.
                // You can pass nil for this closure if not necessary.
            }, completion: { (context) -> Void in
                self.tableView?.reloadData()
                self.view.setNeedsUpdateConstraints()
            })
    }
    
    func addNewList(sender:UIButton?) {
        let addListViewController:TLIAddListViewController = TLIAddListViewController()
        addListViewController.delegate = self
        addListViewController.mode = "create"
        let navigationController:UINavigationController = UINavigationController(rootViewController: addListViewController);
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Add New List", properties: nil)
    }
    
    // MARK: Display Setup
    func displaySetup() {
        let setupViewController:TLISetupViewController = TLISetupViewController()
        let navigationController:UINavigationController = UINavigationController(rootViewController: setupViewController);
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet;
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Setup", properties: nil)
    }
    
    func displayArchive(button:TLIArchiveButton) {
        let settingsViewController:TLIArchiveViewController = TLIArchiveViewController()
        let navigationController:UINavigationController = UINavigationController(rootViewController: settingsViewController);
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet;
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Display Archive", properties: nil)
    }
    
    // MARK: Display Settings
    
    func displaySettings(sender: UIButton) {
        let settingsViewController:TLISettingsTableViewController = TLISettingsTableViewController()
        let navigationController:UINavigationController = UINavigationController(rootViewController: settingsViewController);
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet;
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Display Settings", properties: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController!.active = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController!.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForLists()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let displaySetupScreen:NSString = userDefaults.objectForKey("kSetupScreen") as! NSString
        
        if displaySetupScreen == "on" {
            $.delay(0.1, closure: { () -> () in
                self.displaySetup()
            })
        } else if displaySetupScreen == "off" {
            startSync()
        }
        if tableView!.indexPathForSelectedRow != nil {
            tableView?.deselectRowAtIndexPath(tableView!.indexPathForSelectedRow!, animated: animated)
        }
        initEstimatedRowHeightCacheIfNeeded()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "toggleEditMode:")
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "toggleEditMode:")
        }
    }
    
    func toggleEditMode(sender:UIBarButtonItem) {
        setEditing(!editing, animated: true)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit", handler:{action, indexpath in
            //let cdc:TLICDController = TLICDController.sharedInstance
            let list:TLIList = self.frc?.objectAtIndexPath(indexpath) as! TLIList
            
            let addListViewController:TLIAddListViewController = TLIAddListViewController()
            addListViewController.delegate = self
            addListViewController.list = list
            addListViewController.mode = "edit"
            let navigationController:UINavigationController = UINavigationController(rootViewController: addListViewController);
            navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        });
        editRowAction.backgroundColor = UIColor(red: 229.0 / 255.0, green: 230.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        
        let archiveRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Archive", handler:{action, indexpath in
            let list:TLIList = self.frc?.objectAtIndexPath(indexpath) as! TLIList
            
            let cdc:TLICDController = TLICDController.sharedInstance
            //First we must delete local notification
            let app:UIApplication = UIApplication.sharedApplication()
            let notifications:NSArray = app.scheduledLocalNotifications!
            
            for task in list.tasks! {
                let tmpTask:TLITask = task as! TLITask
                
                if let _ = tmpTask.notification {
                    for notification in notifications {
                        let temp:UILocalNotification = notification as! UILocalNotification
                        
                        if let userInfo:NSDictionary = temp.userInfo {
                       
                            let uniqueIdentifier: String? = userInfo.valueForKey("uniqueIdentifier") as? String
                            
                            if uniqueIdentifier == tmpTask.notification!.uniqueIdentifier {
                                
                                let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Notification")
                                let positionDescriptor  = NSSortDescriptor(key: "uniqueIdentifier", ascending: false)
                                fetchRequest.sortDescriptors = [positionDescriptor]
                                fetchRequest.predicate = NSPredicate(format: "uniqueIdentifier = %@", uniqueIdentifier!)
                                fetchRequest.fetchLimit = 1
                                
                                do {
                                    let results:NSArray = try cdc.context!.executeFetchRequest(fetchRequest)
                                    let notification:TLINotification = results.lastObject as! TLINotification
                                    
                                    cdc.context?.deleteObject(notification)
                                    
                                    app.cancelLocalNotification(temp)
                                } catch let error as NSError {
                                    fatalError(error.localizedDescription)
                                }
                                
                            }
                        }
                    }
                }
            }
            
            list.archivedAt = NSDate()
            cdc.backgroundSaveContext()
            self.checkForLists()
        });
        archiveRowAction.backgroundColor = UIColor.tinylogMainColor()
        return [archiveRowAction, editRowAction];
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func listAtIndexPath(indexPath:NSIndexPath)->TLIList? {
        let list = self.frc?.objectAtIndexPath(indexPath) as! TLIList!
        return list
    }
    
    func updateList(list:TLIList, sourceIndexPath:NSIndexPath, destinationIndexPath:NSIndexPath) {
        var fetchedLists:[AnyObject] = self.frc?.fetchedObjects as [AnyObject]!
        
        //println(fetchedLists)
        fetchedLists = fetchedLists.filter() { $0 as! TLIList != list }
        //println(fetchedLists)
        
        let index = destinationIndexPath.row
        fetchedLists.insert(list, atIndex: index)
        
        var i:NSInteger = fetchedLists.count
        for (_, list) in fetchedLists.enumerate() {
            let t = list as! TLIList
            t.position = NSNumber(integer: i--)
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return;
        }
        
        //Disable fetched results controller
        self.ignoreNextUpdates = true
        let list = self.listAtIndexPath(sourceIndexPath)!
        updateList(list, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
        let cdc:TLICDController = TLICDController.sharedInstance
        cdc.backgroundSaveContext()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return floor(getEstimatedCellHeightFromCache(indexPath, defaultHeight: 61)!)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! TLIListTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        let success = isEstimatedRowHeightInCache(indexPath)
        
        if (success != nil) {
            let cellSize:CGSize = cell.systemLayoutSizeFittingSize(CGSizeMake(self.view.frame.size.width, 0), withHorizontalFittingPriority: 1000, verticalFittingPriority: 61)
            putEstimatedCellHeightToCache(indexPath, height: cellSize.height)
        }
        return cell
    }
    
    override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let list:TLIList = self.frc?.objectAtIndexPath(indexPath) as! TLIList
        let listTableViewCell:TLIListTableViewCell = cell as! TLIListTableViewCell
        listTableViewCell.currentList = list
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var list:TLIList
        
        if tableView == self.tableView {
            list = self.frc?.objectAtIndexPath(indexPath) as! TLIList
        } else {
            list = resultsTableViewController?.frc?.objectAtIndexPath(indexPath) as! TLIList
        }
        
        let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
        
        if  IS_IPAD {
            TLISplitViewController.sharedSplitViewController().listViewController?.managedObject = list
            TLISplitViewController.sharedSplitViewController().listViewController?.title = list.title
        } else {
            let tasksViewController:TLITasksViewController = TLITasksViewController()
            tasksViewController.list = list
            self.navigationController?.pushViewController(tasksViewController, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Delete"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle != UITableViewCellEditingStyle.Delete {
            return
        }
        
        let list:TLIList = self.frc?.objectAtIndexPath(indexPath) as! TLIList
        
        let cdc:TLICDController = TLICDController.sharedInstance
        cdc.context!.deleteObject(list)
        cdc.backgroundSaveContext()
    }
    
    func performBackgroundUpdates(completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func onClose(addListViewController:TLIAddListViewController, list:TLIList) {
        
        let indexPath = self.frc?.indexPathForObject(list)
        self.tableView?.selectRowAtIndexPath(indexPath!, animated: true, scrollPosition: UITableViewScrollPosition.None)
        
        let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
        
        if IS_IPAD {
            TLISplitViewController.sharedSplitViewController().listViewController?.managedObject = list
        } else {
            let tasksViewController:TLITasksViewController = TLITasksViewController()
            tasksViewController.list = list
            tasksViewController.focusTextField = true
            self.navigationController?.pushViewController(tasksViewController, animated: true)
        }
        
        checkForLists()
    }
    
    func putEstimatedCellHeightToCache(indexPath:NSIndexPath, height:CGFloat) {
        initEstimatedRowHeightCacheIfNeeded()
        estimatedRowHeightCache?.setValue(height, forKey: NSString(format: "%ld", indexPath.row) as String)
    }
    
    func initEstimatedRowHeightCacheIfNeeded() {
        if estimatedRowHeightCache == nil {
            estimatedRowHeightCache = NSMutableDictionary()
        }
    }
    
    func getEstimatedCellHeightFromCache(indexPath:NSIndexPath, defaultHeight:CGFloat)->CGFloat? {
        initEstimatedRowHeightCacheIfNeeded()
        
        let height:CGFloat? = estimatedRowHeightCache!.valueForKey(NSString(format: "%ld", indexPath.row) as String) as? CGFloat
        
        if( height != nil) {
            return floor(height!)
        }
        return defaultHeight
    }
    
    func isEstimatedRowHeightInCache(indexPath:NSIndexPath)->Bool? {
        let value = getEstimatedCellHeightFromCache(indexPath, defaultHeight: 0)
        if value > 0 {
            return true
        }
        return false
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        resultsTableViewController?.frc?.delegate = nil
        resultsTableViewController?.frc = nil
    }
    
    // MARK: UISearchControllerDelegate
    
    func presentSearchController(searchController: UISearchController) {}
    
    func willPresentSearchController(searchController: UISearchController) {
        topBarView = UIView(frame: CGRectMake(0.0, 0.0, self.view.frame.size.width, 20.0))
        topBarView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        TLIAppDelegate.sharedAppDelegate().window?.rootViewController?.view.addSubview(topBarView!)
    }
    
    func didPresentSearchController(searchController: UISearchController) {}
    
    func willDismissSearchController(searchController: UISearchController) {
        topBarView?.removeFromSuperview()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        let resultsController = searchController.searchResultsController as! TLIResultsTableViewController
        resultsController.frc?.delegate = nil;
        resultsController.frc = nil
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if searchController.searchBar.text!.length() > 0 {
            let color = findColorByName(searchController.searchBar.text!.lowercaseString)
            let resultsController = searchController.searchResultsController as! TLIResultsTableViewController
            let cdc:TLICDController = TLICDController.sharedInstance
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "List")
            let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
            let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@ AND archivedAt = nil", searchController.searchBar.text!.lowercaseString)
            let colorPredicate = NSPredicate(format: "color CONTAINS[cd] %@ AND archivedAt = nil", color)
        
            let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, colorPredicate])
            fetchRequest.predicate = predicate
            resultsController.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cdc.context!, sectionNameKeyPath: nil, cacheName: nil)
            resultsController.frc?.delegate = self;
            
            do {
                try resultsController.frc?.performFetch()
                resultsController.tableView?.reloadData()
                resultsController.checkForResults()
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func findColorByName(name:String)->String {
        switch name {
        case "purple":
            return "#6a6de2"
        case "blue":
            return "#008efe"
        case "red":
            return "#fe4565"
        case "orange":
            return "#ffa600"
        case "green":
            return "#50de72"
        case "yellow":
            return "#ffd401"
        default:
            return ""
        }
    }
}

