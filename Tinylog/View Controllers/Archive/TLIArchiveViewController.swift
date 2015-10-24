//
//  TLIArchiveViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import CoreData
import Reachability

class TLIArchiveViewController: TLICoreDataTableViewController, UITextFieldDelegate, TLIAddListViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
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
    
    func configureFetch() {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt != nil")
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cdc.context!, sectionNameKeyPath: nil, cacheName: nil)
        self.frc?.delegate = self
        
        do {
             try self.frc?.performFetch()
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    lazy var noListsLabel:UILabel? = {
        let noTasksLabel:UILabel = UILabel()
        noTasksLabel.font = UIFont.tinylogFontOfSize(16.0)
        noTasksLabel.textColor = UIColor.tinylogTextColor()
        noTasksLabel.textAlignment = NSTextAlignment.Center
        noTasksLabel.text = "No Archives"
        noTasksLabel.frame = CGRectMake(self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 - 44.0 / 2.0, self.view.frame.size.width, 44.0)
        return noTasksLabel
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFetch()
        
        self.title = "My Archives"
        
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.backgroundView = UIView()
        self.tableView?.backgroundView?.backgroundColor = UIColor.clearColor()
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView?.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        
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
        
        self.view.addSubview(self.noListsLabel!)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Plain, target: self, action: "close:")
        
        setEditing(false, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidEndNotification:", name: IDMSyncActivityDidEndNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidBeginNotification:", name: IDMSyncActivityDidBeginNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFonts", name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onChangeSize:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        definesPresentationContext = true
        
    }
    
    func onChangeSize(notification:NSNotification) {
        self.tableView?.reloadData()
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
        }
    }
    
    func syncActivityDidBeginNotification(notification:NSNotification) {
        if TLISyncManager.sharedSyncManager().canSynchronize() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
    }
    
    func reachabilityChanged(notification:NSNotification) {
        let reachability:Reachability = notification.object as! Reachability
        if reachability.isReachable() {
            
        }
    }
    
    // MARK: Close
    func close(button:UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.noListsLabel!.frame = CGRectMake(self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 - 44.0 / 2.0, self.view.frame.size.width, 44.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkForLists()
        if tableView!.indexPathForSelectedRow != nil {
            tableView?.deselectRowAtIndexPath(tableView!.indexPathForSelectedRow!, animated: animated)
        }
        initEstimatedRowHeightCacheIfNeeded()
    }
    
    func checkForLists() {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "List")
        let positionDescriptor = NSSortDescriptor(key: "position", ascending: false)
        let titleDescriptor  = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, titleDescriptor]
        fetchRequest.predicate = NSPredicate(format: "archivedAt != nil")
        
        do {
            let results = try cdc.context?.executeFetchRequest(fetchRequest)
            
            if results?.count == 0 {
                self.noListsLabel?.hidden = false
            } else {
                self.noListsLabel?.hidden = true
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            let cdc:TLICDController = TLICDController.sharedInstance
            let list:TLIList = self.frc?.objectAtIndexPath(indexpath) as! TLIList
            
            //First we must delete local notification
            let app:UIApplication = UIApplication.sharedApplication()
            let notifications:NSArray = app.scheduledLocalNotifications!
            
            for task in list.tasks! {
                let tmpTask:TLITask = task as! TLITask
                
                if let _ = tmpTask.notification {
                    for notification in notifications {
                        let temp:UILocalNotification = notification as! UILocalNotification
                        
                        if let userInfo:NSDictionary = temp.userInfo {
                            //let displayText: String? = userInfo.valueForKey("displayText") as? String
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
            
            cdc.context?.deleteObject(list)
            cdc.backgroundSaveContext()
            self.checkForLists()
        });
        deleteRowAction.backgroundColor = UIColor(red: 254.0 / 255.0, green: 69.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
        
        let restoreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Restore", handler:{action, indexpath in
            let list:TLIList = self.frc?.objectAtIndexPath(indexpath) as! TLIList
            let cdc:TLICDController = TLICDController.sharedInstance
            
            //re-enable local notification
            
            for task in list.tasks! {
                let tmpTask:TLITask = task as! TLITask
                
                if let reminder = tmpTask.reminder {
                    if reminder.timeIntervalSinceNow < 0.0 {
                        //println("time has passed")
                    } else {
                        let notification:TLINotification = NSEntityDescription.insertNewObjectForEntityForName("Notification", inManagedObjectContext: cdc.context!) as! TLINotification
                        notification.displayText = tmpTask.displayLongText
                        notification.fireDate = tmpTask.reminder!
                        notification.createdAt = NSDate()
                        
                        //create the relationship
                        tmpTask.notification = notification
                        
                        let syncManager:TLISyncManager = TLISyncManager.sharedSyncManager()
                        if syncManager.canSynchronize() {
                            syncManager.synchronizeWithCompletion { (error) -> Void in
                            }
                        } else {
                            NSNotificationCenter.defaultCenter().postNotificationName(IDMSyncActivityDidEndNotification, object: nil)
                        }
                    }
                }
            }
            
            list.archivedAt = nil
            cdc.backgroundSaveContext()
            self.checkForLists()
        });
        restoreRowAction.backgroundColor = UIColor.tinylogMainColor()
        return [restoreRowAction, deleteRowAction];
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
        
        //println(fetchedLists)
        
        for (_, _) in fetchedLists.enumerate() {
            //let t = list as! TLIList
            //println("before \(t.title): \(t.position)")
        }
        
        
        //        var i:NSInteger = 1
        //        for (index, list) in enumerate(fetchedLists) {
        //            let t = list as TLIList
        //            t.position = NSNumber(integer: i++)
        //            println("Item \(index): \(t.position)")
        //        }
        
        var i:NSInteger = fetchedLists.count
        for (_, list) in fetchedLists.enumerate() {
            let t = list as! TLIList
            t.position = NSNumber(integer: i--)
            //println("Item \(index): \(t.position)")
        }
        
        for (_, list) in fetchedLists.enumerate() {
            _ = list as! TLIList
            //println("after \(t.title): \(t.position)")
        }
        
        //reverse
        
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return;
        }
        
        //Disable fetched results controller
        self.ignoreNextUpdates = true
        let list = self.listAtIndexPath(sourceIndexPath)!
        //println("list \(list.title)")
        updateList(list, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
        
        
        //var listSource:TLIList = self.frc?.objectAtIndexPath(sourceIndexPath) as! TLIList
        //println("source \(listSource.position)")
        
        //var listDestination:TLIList = self.frc?.objectAtIndexPath(destinationIndexPath) as! TLIList
        //println("destination \(listDestination.position)")
        
        let cdc:TLICDController = TLICDController.sharedInstance
        cdc.backgroundSaveContext()
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //52.0
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
            TLISplitViewController.sharedSplitViewController().listViewController?.enableDidSelectRowAtIndexPath = false
        } else {
            let tasksViewController:TLITasksViewController = TLITasksViewController()
            tasksViewController.enableDidSelectRowAtIndexPath = false
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
        let tasksViewController:TLITasksViewController = TLITasksViewController()
        tasksViewController.list = list
        tasksViewController.focusTextField = true
        self.navigationController?.pushViewController(tasksViewController, animated: true)
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
    
    func didPresentSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        topBarView?.removeFromSuperview()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
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
            let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@ AND archivedAt != nil", searchController.searchBar.text!.lowercaseString)
            let colorPredicate = NSPredicate(format: "color CONTAINS[cd] %@ AND archivedAt != nil", color)
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

