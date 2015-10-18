//
//  TLIHelpTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import MessageUI

class TLIHelpTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var estimatedRowHeightCache:NSMutableDictionary?
    let helpCellIdentifier = "HelpCellIdentifier"
    var helpArr = [
        "Create a new list by tapping Plus icon at bottom left",
        "Search all your lists with the search field at the top",
        "Search all your lists with by typing 'purple', 'blue', 'red', 'orange', 'green', 'yellow' tags",
        "Create a new task by tapping text field at the top",
        "View tasks by tapping a list",
        "View archives by tapping Archive icon at bottom right",
        "Reorder lists and tasks by tapping 'Edit'",
        "Archive a list by swiping to the left and tapping 'Archive'",
        "Edit a list by swiping to the left and tapping 'Edit'",
        "Delete a list by swiping to the left and tapping 'Delete'",
        "Restore a list by swiping to the left and tapping 'Restore'",
        "Tap checkbox to complete tasks",
        "Organize tasks with #hashtags",
        "Organize tasks with @mentions",
        "Create web links by typing http:// for example http://www.tinylogapp.com",
        "Enable iCloud by tapping Settings icon",
        "Change font or size by tapping Settings icon",
        "Thanks for choosing Tinylog"]
    
    
    // MARK: Initializers
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Plain)
    }
    
    required  init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        
        self.tableView?.backgroundView = UIView()
        self.tableView?.backgroundView?.backgroundColor = UIColor.clearColor()
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView?.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 50.0)
        
        self.tableView?.registerClass(TLIHelpTableViewCell.self, forCellReuseIdentifier: helpCellIdentifier)
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 61
        
        self.title = "Help"
        
        self.navigationController?.interactivePopGestureRecognizer!.enabled = true
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFonts", name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
    }
    
    func updateFonts() {
        self.navigationController?.navigationBar.setNeedsDisplay()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initEstimatedRowHeightCacheIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configureCell(cell:UITableViewCell, indexPath:NSIndexPath) {
        let helpTableViewCell:TLIHelpTableViewCell = cell as! TLIHelpTableViewCell
        helpTableViewCell.helpLabel.text = helpArr[indexPath.row]
    }
    
    // MARK: Actions
    
    func close(sender:UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return floor(getEstimatedCellHeightFromCache(indexPath, defaultHeight: 61)!)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpArr.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(helpCellIdentifier) as! TLIHelpTableViewCell
        self.configureCell(cell, indexPath: indexPath)
        
        let success = isEstimatedRowHeightInCache(indexPath)
        
        if (success != nil) {
            let cellSize:CGSize = cell.systemLayoutSizeFittingSize(CGSizeMake(self.view.frame.size.width, 0), withHorizontalFittingPriority: 1000, verticalFittingPriority: 61)
            putEstimatedCellHeightToCache(indexPath, height: cellSize.height)
        }
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {}
    
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
}

