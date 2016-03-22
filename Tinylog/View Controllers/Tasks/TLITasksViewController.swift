//
//  TLITasksViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TLITasksViewController: TLICoreDataTableViewController, TLIAddTaskViewDelegate, TTTAttributedLabelDelegate, TLIEditTaskViewControllerDelegate {
    
    let kCellIdentifier = "CellIdentifier"
    let kReminderCellIdentifier = "ReminderCellIdentifier"
    var list:TLIList? = nil
    var offscreenCells:NSMutableDictionary?
    var estimatedRowHeightCache:NSMutableDictionary?
    var currentIndexPath:NSIndexPath?
    var focusTextField:Bool?
    
    var topConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    var tasksFooterView:TLITasksFooterView? = {
        let tasksFooterView = TLITasksFooterView.newAutoLayoutView()
        return tasksFooterView
    }()
    
    var orientation:String = "portrait"
    var enableDidSelectRowAtIndexPath = true
    var didSetupContraints = false
    
    lazy var addTransparentLayer:UIView? = {
        let addTransparentLayer:UIView = UIView.newAutoLayoutView()
        addTransparentLayer.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleBottomMargin]
        addTransparentLayer.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        addTransparentLayer.alpha = 0.0
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TLITasksViewController.transparentLayerTapped(_:)))
        addTransparentLayer.addGestureRecognizer(tapGestureRecognizer)
        return addTransparentLayer
    }()
    
    lazy var noTasksLabel:UILabel? = {
        let noTasksLabel:UILabel = UILabel.newAutoLayoutView()
        noTasksLabel.font = UIFont.regularFontWithSize(18.0)
        noTasksLabel.textColor = UIColor.tinylogTextColor()
        noTasksLabel.text = "Tap text field to create a new task."
        noTasksLabel.hidden = true
        return noTasksLabel
    }()
    
    lazy var noListSelected:UILabel? = {
        let noListSelected:UILabel = UILabel.newAutoLayoutView()
        noListSelected.font = UIFont.regularFontWithSize(16.0)
        noListSelected.textColor = UIColor.tinylogTextColor()
        noListSelected.textAlignment = NSTextAlignment.Center
        noListSelected.text = "No List Selected"
        noListSelected.sizeToFit()
        noListSelected.hidden = true
        return noListSelected
    }()

    lazy var addTaskView:TLIAddTaskView? = {
        let header:TLIAddTaskView = TLIAddTaskView(frame: CGRectMake(0.0, 0.0, self.tableView!.bounds.size.width, TLIAddTaskView.height()))
        header.closeButton?.addTarget(self, action: #selector(TLITasksViewController.transparentLayerTapped(_:)), forControlEvents: UIControlEvents.TouchDown)
        header.delegate = self
        return header
    }()
    
    func getDetailViewSize() -> CGSize {
        var detailViewController: UIViewController
        if (self.splitViewController?.viewControllers.count > 1) {
            detailViewController = (self.splitViewController?.viewControllers[1])!
        } else {
            detailViewController = (self.splitViewController?.viewControllers[0])!
        }
        return detailViewController.view.frame.size
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    var managedObject:TLIList? {
        willSet {
            
            if newValue != nil {
                self.noListSelected?.hidden = true
            } else {
                self.noListSelected?.hidden = false
            }
            
            let cdc:TLICDController = TLICDController.sharedInstance
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Task")
            let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
            let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
            fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
            fetchRequest.predicate  = NSPredicate(format: "list = %@ AND archivedAt = nil", newValue!)
            fetchRequest.fetchBatchSize = 20
            self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cdc.context!, sectionNameKeyPath: nil, cacheName: nil)
            self.frc?.delegate = self
            
            do {
                try self.frc?.performFetch()
                self.tableView?.reloadData()
                self.checkForTasks()
                updateFooterInfoText(newValue!)
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
        fetchRequest.predicate  = NSPredicate(format: "list = %@ AND archivedAt = nil", self.list!)
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
        
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        
        self.tableView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView?.registerClass(TLITaskTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView?.registerClass(TLIReminderTaskTableViewCell.self, forCellReuseIdentifier: kReminderCellIdentifier)
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = TLITableViewCell.cellHeight()
        self.tableView?.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 50.0)
    
        tasksFooterView?.exportTasksButton?.addTarget(self, action: #selector(TLITasksViewController.exportTasks(_:)), forControlEvents: UIControlEvents.TouchDown)
        tasksFooterView?.archiveButton?.addTarget(self, action: #selector(TLITasksViewController.displayArchive(_:)), forControlEvents: UIControlEvents.TouchDown)
        
        let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
        
        if IS_IPAD {
            self.title = managedObject?.title
        } else {
            self.title = list?.title
            configureFetch()
            updateFooterInfoText(list!)
        }
        
        setEditing(false, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TLITasksViewController.onChangeSize(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TLITasksViewController.syncActivityDidEndNotification(_:)), name: IDMSyncActivityDidEndNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TLITasksViewController.syncActivityDidBeginNotification(_:)), name: IDMSyncActivityDidBeginNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TLITasksViewController.appBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TLITasksViewController.updateFonts), name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
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
    
    func updateFooterInfoText(list:TLIList) {
        //Fetch all objects from list
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequestTotal:NSFetchRequest = NSFetchRequest(entityName: "Task")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        fetchRequestTotal.sortDescriptors = [positionDescriptor]
        fetchRequestTotal.predicate  = NSPredicate(format: "archivedAt = nil AND list = %@", list)
        fetchRequestTotal.fetchBatchSize = 20
        
        do {
            let results:NSArray = try cdc.context!.executeFetchRequest(fetchRequestTotal)
            
            let fetchRequestCompleted:NSFetchRequest = NSFetchRequest(entityName: "Task")
            fetchRequestCompleted.sortDescriptors = [positionDescriptor]
            fetchRequestCompleted.predicate  = NSPredicate(format: "archivedAt = nil AND completed = %@ AND list = %@", NSNumber(bool: false), list)
            fetchRequestCompleted.fetchBatchSize = 20
            let resultsCompleted:NSArray = try cdc.context!.executeFetchRequest(fetchRequestCompleted)
            
            let total:Int = results.count - resultsCompleted.count
            
            if total == results.count {
                tasksFooterView?.updateInfoLabel("All tasks completed")
            } else {
                if total > 1 {
                    tasksFooterView?.updateInfoLabel("\(total) completed tasks")
                } else {
                    tasksFooterView?.updateInfoLabel("\(total) completed task")
                }
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func syncActivityDidEndNotification(notification:NSNotification) {
        if TLISyncManager.sharedSyncManager().canSynchronize() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            checkForTasks()
        }
    }
    
    func syncActivityDidBeginNotification(notification:NSNotification) {
        if TLISyncManager.sharedSyncManager().canSynchronize() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            checkForTasks()
        }
    }
    
    override func loadView() {
        super.loadView()

        view.addSubview(noListSelected!)
        view.addSubview(noTasksLabel!)
        view.addSubview(tasksFooterView!)
        view.addSubview(addTransparentLayer!)
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        
        if !didSetupContraints {
                    
            noListSelected?.autoCenterInSuperview()
            noTasksLabel?.autoCenterInSuperview()
            
            tasksFooterView?.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            tasksFooterView?.autoSetDimension(.Height, toSize: 51.0)
            tasksFooterView?.autoPinEdgeToSuperviewEdge(.Left)
            tasksFooterView?.autoPinEdgeToSuperviewEdge(.Bottom)
            
            addTransparentLayer?.autoMatchDimension(.Width, toDimension: .Width, ofView: self.view)
            
            didSetupContraints = true
        }
        
        topConstraint?.autoRemove()
        heightConstraint?.autoRemove()
        
        var posY:CGFloat = 0.0
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            if self.orientation == "portrait" {
                posY = 64.0 + TLIAddTaskView.height()
            } else {
                posY = 64.0 + TLIAddTaskView.height()
            }
        } else {
            if self.orientation == "portrait" {
                posY = 64.0 + TLIAddTaskView.height()
            } else {
                posY = 32.0 + TLIAddTaskView.height()
            }
        }
        
        topConstraint = addTransparentLayer?.autoPinEdgeToSuperviewEdge(.Top, withInset: posY)
        heightConstraint = addTransparentLayer?.autoMatchDimension(.Height, toDimension: .Height, ofView: self.view, withOffset: -51.0 - posY)

        super.updateViewConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.checkForTasks()
        
        let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
        
        if IS_IPAD {
            self.noListSelected?.hidden = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        setEditing(false, animated: false)
    }
    
    func displayArchive(button:TLIArchiveButton) {
        let viewController:TLIArchiveTasksViewController = TLIArchiveTasksViewController()
        
        let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
        
        if IS_IPAD {
            viewController.list = managedObject
        } else {
            viewController.list = list
        }
        
        let navigationController:UINavigationController = UINavigationController(rootViewController: viewController);
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet;
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Display Archive Tasks", properties: nil)
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
        
        if (focusTextField != nil) {
            self.addTaskView?.textField?.becomeFirstResponder()
            focusTextField = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TLITasksViewController.toggleEditMode(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TLITasksViewController.toggleEditMode(_:)))
        }
    }
    
    func toggleEditMode(sender:UIBarButtonItem) {
        setEditing(!editing, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let archiveRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Archive", handler:{action, indexpath in
            let task:TLITask = self.frc?.objectAtIndexPath(indexpath) as! TLITask
            let cdc:TLICDController = TLICDController.sharedInstance
            
            //First we must delete local notification if reminder exists
            
            if let _ = task.reminder {
                let app:UIApplication = UIApplication.sharedApplication()
                let notifications:NSArray = app.scheduledLocalNotifications!
                
                for notification in notifications {
                    let temp:UILocalNotification = notification as! UILocalNotification
                    
                    if let userInfo:NSDictionary = temp.userInfo {
          
                        let uniqueIdentifier: String? = userInfo.valueForKey("uniqueIdentifier") as? String
                        
                        if let taskNotification = task.notification {
                            if uniqueIdentifier == taskNotification.uniqueIdentifier {
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
            
            task.archivedAt = NSDate()
            
            //update counter list
            //Fetch all objects from list
            let fetchRequestTotal:NSFetchRequest = NSFetchRequest(entityName: "Task")
            let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
            fetchRequestTotal.sortDescriptors = [positionDescriptor]
            fetchRequestTotal.predicate  = NSPredicate(format: "archivedAt = nil AND list = %@", task.list!)
            fetchRequestTotal.fetchBatchSize = 20
            
            do {
                let results:NSArray = try cdc.context!.executeFetchRequest(fetchRequestTotal)
                
                let fetchRequestCompleted:NSFetchRequest = NSFetchRequest(entityName: "Task")
                fetchRequestCompleted.sortDescriptors = [positionDescriptor]
                fetchRequestCompleted.predicate  = NSPredicate(format: "archivedAt = nil AND completed = %@ AND list = %@", NSNumber(bool: true), task.list!)
                fetchRequestCompleted.fetchBatchSize = 20
                let resultsCompleted:NSArray = try cdc.context!.executeFetchRequest(fetchRequestCompleted)
                
                let total:Int = results.count - resultsCompleted.count
                task.list!.total = total
                
                cdc.backgroundSaveContext()
                self.setEditing(false, animated: true)
                self.checkForTasks()
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        });
        archiveRowAction.backgroundColor = UIColor.tinylogMainColor()
        return [archiveRowAction];
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
        
        var i:NSInteger = fetchedTasks.count
        
        for (_, task) in fetchedTasks.enumerate() {
            let t = task as! TLITask
            t.position = NSNumber(integer: i--)
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row == destinationIndexPath.row {
            return;
        }
        
        //Disable fetched results controller
        self.ignoreNextUpdates = true
        let task = self.taskAtIndexPath(sourceIndexPath)!
        updateTask(task, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
        
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
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if enableDidSelectRowAtIndexPath {
            return self.addTaskView
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if enableDidSelectRowAtIndexPath {
            return TLIAddTaskView.height()
        }
        return 0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return floor(getEstimatedCellHeightFromCache(indexPath, defaultHeight: 52)!)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let task:TLITask = self.frc?.objectAtIndexPath(indexPath) as! TLITask
        
        if task.reminder != nil {
            let cell:TLIReminderTaskTableViewCell = tableView.dequeueReusableCellWithIdentifier(kReminderCellIdentifier) as! TLIReminderTaskTableViewCell!
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.checkBoxButton.addTarget(self, action: #selector(TLITasksViewController.toggleComplete(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
            cell.checkBoxButton.addTarget(self, action: #selector(TLITasksViewController.toggleComplete(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if enableDidSelectRowAtIndexPath {
            let itemID:NSManagedObjectID = self.frc!.objectAtIndexPath(indexPath).objectID!
            
            do {
                let task:TLITask = try self.frc?.managedObjectContext.existingObjectWithID(itemID) as! TLITask
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.editTask(task, indexPath: indexPath)
                }
            } catch let error as NSError {
              fatalError(error.localizedDescription)
            }
        }
    }
    
    func toggleComplete(button:TLICheckBoxButton) {
        if enableDidSelectRowAtIndexPath {
            let cdc:TLICDController = TLICDController.sharedInstance
            
            let button:TLICheckBoxButton = button as TLICheckBoxButton
            let indexPath:NSIndexPath?  = self.tableView?.indexPathForCell(button.tableViewCell!)!
            
            if !(indexPath != nil) {
                return
            }
            
            let task:TLITask = self.frc?.objectAtIndexPath(indexPath!) as! TLITask
            
            if task.completed!.boolValue {
                task.completed = NSNumber(bool: false)
                task.checkBoxValue = "false"
                task.completedAt = nil
            } else {
                task.completed = NSNumber(bool: true)
                task.checkBoxValue = "true"
                task.completedAt = NSDate()
            }
            
            task.updatedAt = NSDate()
            
            let animation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = NSNumber(float: 1.4)
            animation.toValue = NSNumber(float: 1.0)
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1, 1)
            button.layer.addAnimation(animation, forKey: "bounceAnimation")
            
            cdc.backgroundSaveContext()
            
            let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
            
            
            if IS_IPAD {
                updateFooterInfoText(self.managedObject!)
            } else {
                updateFooterInfoText(self.list!)
            }
            
            TLIAnalyticsTracker.trackMixpanelEvent("Toggle Task", properties: nil)
        }
    }
    
    // MARK: TLIAddTaskViewDelegate
    func addTaskViewDidBeginEditing(addTaskView: TLIAddTaskView) {
        displayTransparentLayer();
    }
    
    func addTaskViewDidEndEditing(addTaskView: TLIAddTaskView) {
        hideTransparentLayer()
    }
    
    func addTaskView(addTaskView: TLIAddTaskView, title: NSString) {
        
        do {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Task")
            let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
            
            let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
            
            if IS_IPAD {
                fetchRequest.predicate = NSPredicate(format: "list = %@", self.managedObject!)
            } else {
                fetchRequest.predicate = NSPredicate(format: "list = %@", self.list!)
            }
            
            fetchRequest.sortDescriptors = [positionDescriptor]
            let results:NSArray = try TLICDController.sharedInstance.context!.executeFetchRequest(fetchRequest)
            
            let cdc:TLICDController = TLICDController.sharedInstance
            let task:TLITask = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: cdc.context!) as! TLITask
            task.displayLongText = title as String
            
            if IS_IPAD {
                task.list = self.managedObject!
            } else {
                task.list = self.list!
            }
            
            task.position = NSNumber(integer: results.count + 1)
            task.createdAt = NSDate()
            task.checkBoxValue = "false"
            task.completed = false
            cdc.backgroundSaveContext()
            
            checkForTasks()
            
            if IS_IPAD {
                updateFooterInfoText(self.managedObject!)
            } else {
                updateFooterInfoText(self.list!)
            }
            
            TLIAnalyticsTracker.trackMixpanelEvent("Add New Task", properties: nil)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func displayTransparentLayer() {
        self.tableView?.scrollEnabled = false
        let addTransparentLayer:UIView = self.addTransparentLayer!
        UIView.animateWithDuration(0.3, delay: 0.0,
            options: [.CurveEaseInOut, .AllowUserInteraction], animations: {
                addTransparentLayer.alpha = 1.0
            }, completion: nil)
    }
    
    func hideTransparentLayer() {
        self.tableView?.scrollEnabled = true
        UIView.animateWithDuration(0.3, delay: 0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction], animations: {
            self.addTransparentLayer!.alpha = 0.0
            }, completion: { finished in
                if finished {
                    //self.addTransparentLayer?.removeFromSuperview()
                }
        })
    }
    
    // MARK: TTTAttributedLabelDelegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if url.scheme == "tag" {
            let tasksTagsViewController:TLITagsViewController = TLITagsViewController()
            tasksTagsViewController.tag = url.host!
            self.navigationController?.pushViewController(tasksTagsViewController, animated: true)
            TLIAnalyticsTracker.trackMixpanelEvent("Display Tags", properties: nil)
        } else if url.scheme == "http" {
            UIApplication.sharedApplication().openURL(NSURL(string: NSString(format: "http://%@", url.host!) as String)!)
            TLIAnalyticsTracker.trackMixpanelEvent("Display Link", properties: nil)
        } else if url.scheme == "mention" {
            
            let mentionsViewController:TLIMentionsViewController = TLIMentionsViewController()
            mentionsViewController.mention = url.host!
            self.navigationController?.pushViewController(mentionsViewController, animated: true)
            TLIAnalyticsTracker.trackMixpanelEvent("Display Mentions", properties: nil)
        }
    }
        
    func transparentLayerTapped(gesture:UITapGestureRecognizer) {
        self.addTaskView?.textField?.resignFirstResponder()
    }
    
    // MARK: Edit Task
    func editTask(task:TLITask, indexPath:NSIndexPath) {
        let editTaskViewController:TLIEditTaskViewController = TLIEditTaskViewController()
        editTaskViewController.task = task
        editTaskViewController.indexPath = indexPath
        editTaskViewController.delegate = self
        let navigationController:UINavigationController = UINavigationController(rootViewController: editTaskViewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Edit Task", properties: nil)
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
    
    func exportTasks(sender:UIButton) {
        if self.managedObject != nil || self.list != nil {
            
            do {
                let cdc:TLICDController = TLICDController.sharedInstance
                let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Task")
                let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
                let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
                fetchRequest.sortDescriptors = [positionDescriptor, displayLongTextDescriptor]
                
                let IS_IPAD = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
                
                if IS_IPAD {
                    fetchRequest.predicate = NSPredicate(format: "list = %@", self.managedObject!)
                } else {
                    fetchRequest.predicate = NSPredicate(format: "list = %@", self.list!)
                }
                
                fetchRequest.fetchBatchSize = 20
                let tasks:NSArray = try cdc.context!.executeFetchRequest(fetchRequest)
                
                var output:NSString = ""
                var listTitle:NSString = ""
                
                if IS_IPAD {
                    listTitle = self.managedObject!.title!
                } else {
                    listTitle = self.list!.title!
                }
                
                output = output.stringByAppendingString(NSString(format: "%@\n", listTitle) as String)
                
                for task in tasks {
                    let taskItem:TLITask = task as! TLITask
                    let displayLongText:NSString = NSString(format: "- %@\n", taskItem.displayLongText!)
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
                
                if IS_IPAD {
                    let popup:UIPopoverController = UIPopoverController(contentViewController: activityViewController)
                    popup.presentPopoverFromRect(sender.bounds, inView: sender, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
                } else {
                    self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
                }
                
                TLIAnalyticsTracker.trackMixpanelEvent("Export Tasks", properties: nil)
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
        }
    }
}

