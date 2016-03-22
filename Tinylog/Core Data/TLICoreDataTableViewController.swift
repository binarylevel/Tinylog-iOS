//
//  TLICoreDataTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import CoreData

class TLICoreDataTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var tableView:UITableView?
    var frc:NSFetchedResultsController?
    var debug:Bool? = true
    var ignoreNextUpdates:Bool = false
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        tableView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView?.dataSource = self
        tableView?.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    deinit {
        tableView?.dataSource = nil
        tableView?.delegate = nil
    }
    
    override func loadView() {
        super.loadView()
        tableView?.frame = self.view.bounds
        self.view.addSubview(tableView!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView?.flashScrollIndicators()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView?.setEditing(editing, animated: animated)
    }
    
    class func classString() -> String {
        return NSStringFromClass(self)
    }
    
    func performFetch() {
        if debug! {
            print("Running \(NSStringFromClass(TLICoreDataTableViewController)) \(NSStringFromSelector(#function))")
        }
        
        if self.frc != nil {
            
            self.frc?.managedObjectContext.performBlock({ () -> Void in
                do {
                    try self.frc!.performFetch()
                    self.tableView?.reloadData()
                } catch let error as NSError {
                    print("Failed to perform fetch \(error)")
                }
            })
        
        } else {
            print("Failed to fetch the NSFetchedResultsController controller is nil")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        return cell
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.frc?.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = frc!.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    /*func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.frc?.sections![section].name
    }*/
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.frc!.sectionForSectionIndexTitle(title, atIndex: index)
    }
        
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.frc?.sectionIndexTitles
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if ignoreNextUpdates {
            return
        }
        
        self.tableView?.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        if ignoreNextUpdates {
            return
        }
        
        switch type {
        case NSFetchedResultsChangeType.Insert:
            self.tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break;
        case NSFetchedResultsChangeType.Delete:
            self.tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break;
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            if ignoreNextUpdates {
                return
            }
            
            switch(type) {
                
            case .Insert:
                if let newIndexPath = newIndexPath {
                    tableView?.insertRowsAtIndexPaths([newIndexPath],
                        withRowAnimation:UITableViewRowAnimation.Fade)
                }
                
            case .Delete:
                if let indexPath = indexPath {
                    tableView?.deleteRowsAtIndexPaths([indexPath],
                        withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
            case .Update:
                if let indexPath = indexPath {
                    if let cell = tableView!.cellForRowAtIndexPath(indexPath) {
                        self.configureCell(cell, atIndexPath: indexPath)
                    }
                }
                
            case .Move:
                if let indexPath = indexPath {
                    if let newIndexPath = newIndexPath {
                        tableView?.deleteRowsAtIndexPaths([indexPath],
                            withRowAnimation: UITableViewRowAnimation.Fade)
                        tableView?.insertRowsAtIndexPaths([newIndexPath],
                            withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                }
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if ignoreNextUpdates {
            ignoreNextUpdates = false
        } else {
            self.tableView?.endUpdates()
        }
    }
}

