//
//  TLIAddListViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIAddListViewController: UITableViewController, UITextFieldDelegate {
    
    var name:UITextField?
    var menuColorsView:TLIMenuColorsView?
    var delegate:TLIAddListViewControllerDelegate?
    var mode:String?
    var list:TLIList?
    
    init() {
        super.init(style: UITableViewStyle.Grouped)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.tinylogBackgroundColor()
        self.tableView.separatorColor = UIColor.tinylogTableViewLineColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TLIAddListViewController.cancel(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TLIAddListViewController.save(_:)))
        
        menuColorsView = TLIMenuColorsView(frame: CGRectMake(12.0, 200.0, self.view.frame.width, 51.0))
        self.tableView.tableFooterView = menuColorsView
        
        if mode == "create" {
            self.title = "Add List"
        } else if mode == "edit" {
            self.title = "Edit List"
            self.menuColorsView!.currentColor = list?.color
            let index:Int = self.menuColorsView!.findIndexByColor(list!.color!)
            self.menuColorsView?.setSelectedIndex(index)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.name?.becomeFirstResponder()
    }
    
    func cancel(button:UIButton) {
        self.name?.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save(button:UIButton) {
        if mode == "create" {
            createList()
        } else if mode == "edit" {
            saveList()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let textFieldCell:TLITextFieldCell = cell as! TLITextFieldCell
        if indexPath.row == 0 {
            if list != nil {
                textFieldCell.textField?.text = list?.title
            } else {
                textFieldCell.textField?.text = ""
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TLITextFieldCell = TLITextFieldCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellIdentifier")
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell:TLITextFieldCell, indexPath:NSIndexPath) {
        if indexPath.row == 0 {
            cell.textField?.placeholder = "Name"
            cell.backgroundColor = UIColor.whiteColor()
            cell.textField?.returnKeyType = UIReturnKeyType.Go
            cell.textField?.delegate = self
            name = cell.textField
            return
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.name {
            if mode == "create" {
                createList()
            } else if mode == "edit" {
                saveList()
            }
        }
        return false
    }
    
    func saveList() {
        if list != nil {
            list?.title = self.name!.text
            list?.color = self.menuColorsView!.currentColor!
            TLICDController.sharedInstance.backgroundSaveContext()
            self.name?.resignFirstResponder()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func createList() {
        
        let cdc:TLICDController = TLICDController.sharedInstance
        
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "List")
        let positionDescriptor  = NSSortDescriptor(key: "position", ascending: false)
        fetchRequest.sortDescriptors = [positionDescriptor]
        fetchRequest.fetchLimit = 1
        
        do {
            let results:NSArray = try cdc.context!.executeFetchRequest(fetchRequest)
            var position:Int
            
            if results.count == 0 {
                position = 0
            } else {
                let list:TLIList = results.objectAtIndex(0) as! TLIList
                position =  list.position!.integerValue
            }
            
            let list:TLIList = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: cdc.context!) as! TLIList
            list.title = self.name!.text
            list.position = position + 1
            list.color = self.menuColorsView!.currentColor!
            list.createdAt = NSDate()
            cdc.backgroundSaveContext()
            
            self.name?.resignFirstResponder()
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.delegate?.onClose(self, list: list)
                return
            })
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}

