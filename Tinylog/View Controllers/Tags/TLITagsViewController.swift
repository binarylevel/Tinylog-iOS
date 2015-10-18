//
//  TLITagsViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class TLITagsViewController: TLICoreDataTableViewController, TTTAttributedLabelDelegate, TLIEditTaskViewControllerDelegate {
    
    let kCellIdentifier = "CellIdentifier"
    let kReminderCellIdentifier = "ReminderCellIdentifier"
    var list:TLIList? = nil
    var offscreenCells:NSMutableDictionary?
    var estimatedRowHeightCache:NSMutableDictionary?
    var currentIndexPath:NSIndexPath?
    var tag:String?
    
    func configureFetch() {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Task")
        let displayLongTextDescriptor  = NSSortDescriptor(key: "displayLongText", ascending: true)
        fetchRequest.sortDescriptors = [displayLongTextDescriptor]
        fetchRequest.predicate = NSPredicate(format: "ANY tags.name == %@", tag!)
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
        
        self.title = NSString(format: "#%@", tag!) as String
        
        self.view.backgroundColor = UIColor.tinylogBackgroundColor()
        self.tableView?.backgroundColor = UIColor.tinylogBackgroundColor()
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView?.registerClass(TLIReminderTaskTableViewCell.self, forCellReuseIdentifier: kReminderCellIdentifier)
        self.tableView?.registerClass(TLITaskTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = TLITableViewCell.cellHeight()
        
        setEditing(false, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onChangeSize:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidEndNotification:", name: IDMSyncActivityDidEndNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncActivityDidBeginNotification:", name: IDMSyncActivityDidBeginNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFonts", name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
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
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
            cell.checkBoxButton.addTarget(self, action: "toggleComplete:", forControlEvents: UIControlEvents.TouchUpInside)
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
            cell.checkBoxButton.addTarget(self, action: "toggleComplete:", forControlEvents: UIControlEvents.TouchUpInside)
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
    
    func toggleComplete(button:TLICheckBoxButton) {
        
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
            task.completedAt = NSDate()
        } else {
            task.completed = NSNumber(bool: true)
            task.checkBoxValue = "true"
            task.completedAt = nil
        }
        
        task.updatedAt = NSDate()
        
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = NSNumber(float: 1.4)
        animation.toValue = NSNumber(float: 1.0)
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1, 1)
        button.layer.addAnimation(animation, forKey: "bounceAnimation")
        
        cdc.backgroundSaveContext()
    }
    
    // MARK: TTTAttributedLabelDelegate
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {}
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
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
}

