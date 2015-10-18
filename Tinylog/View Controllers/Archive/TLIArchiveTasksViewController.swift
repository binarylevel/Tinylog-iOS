//
//  TLIArchiveTasksViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//


import UIKit
import TTTAttributedLabel

class TLIArchiveTasksViewController: TLICoreDataTableViewController, TTTAttributedLabelDelegate, TLIEditTaskViewControllerDelegate {
    
    let kCellIdentifier = "CellIdentifier"
    let kReminderCellIdentifier = "ReminderCellIdentifier"
    var list:TLIList? = nil
    var offscreenCells:NSMutableDictionary?
    var estimatedRowHeightCache:NSMutableDictionary?
    var currentIndexPath:NSIndexPath?
    var focusTextField:Bool?
    var tasksFooterView:TLITasksFooterView?
    var orientation:String = "portrait"
    
    lazy var noTasksLabel:UILabel? = {
        let noTasksLabel:UILabel = UILabel()
        noTasksLabel.font = UIFont(name: "HelveticaNeue", size: 18.0)
        noTasksLabel.textColor = UIColor.tinylogTextColor()
        noTasksLabel.textAlignment = NSTextAlignment.Center
        noTasksLabel.text = "No Archives"
        noTasksLabel.frame = CGRectMake(self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 - 44.0 / 2.0, self.view.frame.size.width, 44.0)
        return noTasksLabel
        }()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    var managedObject:TLIList? {
        willSet {
            let cdc:TLICDController = TLICDController.sharedInstance
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Task")
            let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
            let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
            fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
            fetchRequest.predicate  = NSPredicate(format: "list = %@", newValue!)
            fetchRequest.fetchBatchSize = 20
            self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cdc.context!, sectionNameKeyPath: nil, cacheName: nil)
            self.frc?.delegate = self
            
            do {
                try self.frc?.performFetch()
                self.tableView?.reloadData()
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        }
        didSet {
        }
    }
    
    func configureFetch() {
        
        if list == nil {
            return
        }
        
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
        fetchRequest.predicate  = NSPredicate(format: "list = %@ AND archivedAt != nil", self.list!)
        fetchRequest.fetchBatchSize = 20
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
        
        self.title = "Archive"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Plain, target: self, action: "close:")
        
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView?.registerClass(TLITaskTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView?.registerClass(TLIReminderTaskTableViewCell.self, forCellReuseIdentifier: kReminderCellIdentifier)
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = TLITableViewCell.cellHeight()
        self.tableView?.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 50.0)
        
        self.view.addSubview(self.noTasksLabel!)
        
        setEditing(false, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onChangeSize:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChanged", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidEndNotification:", name: IDMSyncActivityDidEndNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidBeginNotification:", name: IDMSyncActivityDidBeginNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFonts", name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
    }
    
    func updateFonts() {
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
    
    func deviceOrientationChanged() {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            self.orientation = "landscape"
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            self.orientation = "portrait"
        }
        
//        var posY:CGFloat = 0.0
//        
//        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
//            if self.orientation == "portrait" {
//                posY = 64.0 + TLIAddTaskView.height()
//            } else {
//                posY = 64.0 + TLIAddTaskView.height()
//            }
//        } else {
//            if self.orientation == "portrait" {
//                posY = 64.0 + TLIAddTaskView.height()
//            } else {
//                posY = 32.0 + TLIAddTaskView.height()
//            }
//        }
        
        self.noTasksLabel!.frame = CGRectMake(self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 - 44.0 / 2.0, self.view.frame.size.width, 44.0)
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            self.orientation = "landscape"
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            self.orientation = "portrait"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.checkForTasks()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }
    
    func displayArchive(button:TLIArchiveButton) {
        let settingsViewController:TLIArchiveViewController = TLIArchiveViewController()
        let navigationController:UINavigationController = UINavigationController(rootViewController: settingsViewController);
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet;
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: Close
    func close(button:UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkForTasks() {
        if self.frc?.fetchedObjects?.count == 0 {
            self.noTasksLabel?.hidden = false
        } else {
            self.noTasksLabel?.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tasksFooterView?.frame = CGRectMake(0.0, self.view.frame.size.height - 51.0, self.view.frame.size.width, 51.0)
        
//        var posY:CGFloat = 0.0
//        
//        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
//            if self.orientation == "portrait" {
//                posY = 64.0 + TLIAddTaskView.height()
//            } else {
//                posY = 64.0 + TLIAddTaskView.height()
//            }
//        } else {
//            if self.orientation == "portrait" {
//                posY = 64.0 + TLIAddTaskView.height()
//            } else {
//                posY = 32.0 + TLIAddTaskView.height()
//            }
//        }
        
        self.noTasksLabel!.frame = CGRectMake(self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 - 44.0 / 2.0, self.view.frame.size.width, 44.0)
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
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            let cdc:TLICDController = TLICDController.sharedInstance
            let task:TLITask = self.frc?.objectAtIndexPath(indexpath) as! TLITask
            //Delete the core date entity
            cdc.context?.deleteObject(task)
            cdc.backgroundSaveContext()
            
            self.checkForTasks()
            self.setEditing(false, animated: true)
        });
        deleteRowAction.backgroundColor = UIColor(red: 254.0 / 255.0, green: 69.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
        
        let restoreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Restore", handler:{action, indexpath in
            let task:TLITask = self.frc?.objectAtIndexPath(indexpath) as! TLITask
            let cdc:TLICDController = TLICDController.sharedInstance
            
            //re-enable local notification if time has passed don't enable it.
            
            if let reminder = task.reminder {
                if reminder.timeIntervalSinceNow < 0.0 {
                    //println("time has passed")
                } else {
                    let notification:TLINotification = NSEntityDescription.insertNewObjectForEntityForName("Notification", inManagedObjectContext: cdc.context!) as! TLINotification
                    notification.displayText = task.displayLongText
                    notification.fireDate = task.reminder!
                    notification.createdAt = NSDate()
                    
                    //create the relationship
                    task.notification = notification
                    
                    let syncManager:TLISyncManager = TLISyncManager.sharedSyncManager()
                    if syncManager.canSynchronize() {
                        syncManager.synchronizeWithCompletion { (error) -> Void in
                        }
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName(IDMSyncActivityDidEndNotification, object: nil)
                    }
                }
            }
            
            task.archivedAt = nil
            cdc.backgroundSaveContext()
            self.checkForTasks()
            self.setEditing(false, animated: true)
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
    
    func taskAtIndexPath(indexPath:NSIndexPath)->TLITask? {
        let task = self.frc?.objectAtIndexPath(indexPath) as! TLITask!
        return task
    }
    
    func updateTask(task:TLITask, sourceIndexPath:NSIndexPath, destinationIndexPath:NSIndexPath) {
        var fetchedTasks:[AnyObject] = self.frc?.fetchedObjects as [AnyObject]!
        fetchedTasks = fetchedTasks.filter() { $0 as! TLITask != task }
        let index = destinationIndexPath.row
        fetchedTasks.insert(task, atIndex: index)
        
        //for (index, task) in enumerate(fetchedTasks) {
        // let t = task as! TLITask
        //println("before \(t.displayLongText): \(t.position)")
        //}
        
        
        //        var i:NSInteger = 1
        //        for (index, list) in enumerate(fetchedLists) {
        //            let t = list as TLIList
        //            t.position = NSNumber(integer: i++)
        //            println("Item \(index): \(t.position)")
        //        }
        
        var i:NSInteger = fetchedTasks.count
        for (_, task) in fetchedTasks.enumerate() {
            let t = task as! TLITask
            t.position = NSNumber(integer: i--)
        }
        
        //for (index, task) in enumerate(fetchedTasks) {
        //let t = task as! TLITask
        //println("after \(t.displayLongText): \(t.position)")
        //}
        
        //reverse
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return;
        }
        
        //Disable fetched results controller
        self.ignoreNextUpdates = true
        let task = self.taskAtIndexPath(sourceIndexPath)!
        updateTask(task, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
        
        //var taskSource:TLITask = self.frc?.objectAtIndexPath(sourceIndexPath) as! TLITask
        //var taskDestination:TLITask = self.frc?.objectAtIndexPath(destinationIndexPath) as! TLITask
        
        let cdc:TLICDController = TLICDController.sharedInstance
        cdc.backgroundSaveContext()
    }
    
    func onChangeSize(notification:NSNotification) {
        self.tableView?.reloadData()
    }
    
    override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let task:TLITask = self.frc?.objectAtIndexPath(indexPath) as! TLITask
        if cell is TLIReminderTaskTableViewCell {
            let taskReminderTableViewCell:TLIReminderTaskTableViewCell = cell as! TLIReminderTaskTableViewCell
            taskReminderTableViewCell.currentTask = task
        } else if cell is TLITaskTableViewCell {
            let taskTableViewCell:TLITaskTableViewCell = cell as! TLITaskTableViewCell
            taskTableViewCell.currentTask = task
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return floor(getEstimatedCellHeightFromCache(indexPath, defaultHeight: 52)!)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let task:TLITask = self.frc?.objectAtIndexPath(indexPath) as! TLITask
        
        if task.reminder != nil {
            let cell:TLIReminderTaskTableViewCell = tableView.dequeueReusableCellWithIdentifier(kReminderCellIdentifier) as! TLIReminderTaskTableViewCell!
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.taskLabel.delegate = self
            configureCell(cell, atIndexPath: indexPath)
            
            let height = isEstimatedRowHeightInCache(indexPath)
            if (height != nil) {
                let cellSize:CGSize = cell.systemLayoutSizeFittingSize(CGSizeMake(self.view.frame.size.width, 0), withHorizontalFittingPriority: 1000, verticalFittingPriority: 52)
                putEstimatedCellHeightToCache(indexPath, height: cellSize.height)
            }
            return cell
            
        } else {
            let cell:TLITaskTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! TLITaskTableViewCell!
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.taskLabel.delegate = self
            configureCell(cell, atIndexPath: indexPath)
            
            let height = isEstimatedRowHeightInCache(indexPath)
            if (height != nil) {
                let cellSize:CGSize = cell.systemLayoutSizeFittingSize(CGSizeMake(self.view.frame.size.width, 0), withHorizontalFittingPriority: 1000, verticalFittingPriority: 52)
                putEstimatedCellHeightToCache(indexPath, height: cellSize.height)
            }
            return cell
        }
    }
    
    // MARK: TTTAttributedLabelDelegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if url.scheme == "tag" {
            let tasksTagsViewController:TLITagsViewController = TLITagsViewController()
            tasksTagsViewController.tag = url.host!
            self.navigationController?.pushViewController(tasksTagsViewController, animated: true)
        } else if url.scheme == "http" {
            UIApplication.sharedApplication().openURL(NSURL(string: NSString(format: "http://%@", url.host!) as String)!)
        } else if url.scheme == "mention" {
            let mentionsViewController:TLIMentionsViewController = TLIMentionsViewController()
            mentionsViewController.mention = url.host!
            self.navigationController?.pushViewController(mentionsViewController, animated: true)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    // MARK: Edit Task
    func editTask(task:TLITask, indexPath:NSIndexPath) {
        let editTaskViewController:TLIEditTaskViewController = TLIEditTaskViewController()
        editTaskViewController.task = task
        editTaskViewController.indexPath = indexPath
        editTaskViewController.delegate = self
        var navigationController:UINavigationController = UINavigationController(rootViewController: editTaskViewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
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
        
        var height:CGFloat? = estimatedRowHeightCache!.valueForKey(NSString(format: "%ld", indexPath.row) as String) as? CGFloat
        
        if( height != nil) {
            return height!
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
    
    func tableViewReloadData() {
        estimatedRowHeightCache = NSMutableDictionary()
        self.tableView?.reloadData()
    }
    
    func onClose(editTaskViewController:TLIEditTaskViewController, indexPath:NSIndexPath) {
        self.currentIndexPath = indexPath
        self.tableView?.reloadData()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func exportTasks(sender:UIButton) {
        
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
        fetchRequest.predicate  = NSPredicate(format: "list = %@", self.list!)
        fetchRequest.fetchBatchSize = 20
        let tasks:NSArray = cdc.context!.executeFetchRequest(fetchRequest, error: nil)!
        
        var output:NSString = ""
        
        let listTitle:NSString = self.list!.title
        output = output.stringByAppendingString(NSString(format: "%@\n", listTitle) as String)
        
        for task in tasks {
            let taskItem:TLITask = task as! TLITask
            let displayLongText:NSString = NSString(format: "- %@\n", taskItem.displayLongText)
            output = output.stringByAppendingString(displayLongText as String)
        }
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: [output], applicationActivities: nil)
        activityViewController.excludedActivityTypes =  [
            UIActivityTypePostToTwitter,
            UIActivityTypePostToFacebook,
            UIActivityTypePostToWeibo,
            UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
    }
}

