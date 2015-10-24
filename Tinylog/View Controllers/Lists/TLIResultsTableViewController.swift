//
//  TLIResultsTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIResultsTableViewController: TLICoreDataTableViewController {
    
    let kCellIdentifier = "CellIdentifier"
    
    lazy var noResultsLabel:UILabel? = {
        let noResultsLabel:UILabel = UILabel()
        noResultsLabel.font = UIFont.tinylogFontOfSize(16.0)
        noResultsLabel.textColor = UIColor.tinylogTextColor()
        noResultsLabel.textAlignment = NSTextAlignment.Center
        noResultsLabel.text = "No Results"
        noResultsLabel.frame = CGRectMake(self.view.frame.size.width / 2.0 - self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 - 44.0 / 2.0, self.view.frame.size.width, 44.0)
        return noResultsLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.tinylogBackgroundColor()
        self.tableView?.backgroundColor = UIColor.tinylogBackgroundColor()
        self.tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView?.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        self.tableView?.registerClass(TLIListTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = TLITableViewCell.cellHeight()
        
        self.view.addSubview(self.noResultsLabel!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkForResults()
    }
    
    func checkForResults() {
        if self.frc?.fetchedObjects?.count == 0 {
            self.noResultsLabel?.hidden = false
        } else {
            self.noResultsLabel?.hidden = true
        }
    }
    
    func configureFetch() {
        let cdc:TLICDController = TLICDController.sharedInstance
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "List")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        let remoteIDDescriptor  = NSSortDescriptor(key: "remoteID", ascending: true)
        fetchRequest.sortDescriptors = [positionDescriptor, remoteIDDescriptor]
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cdc.context!, sectionNameKeyPath: nil, cacheName: nil)
        self.frc?.delegate = self
    }
    
    override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let list:TLIList = self.frc?.objectAtIndexPath(indexPath) as! TLIList
        let listTableViewCell:TLIListTableViewCell = cell as! TLIListTableViewCell
        listTableViewCell.currentList = list
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! TLIListTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
}

