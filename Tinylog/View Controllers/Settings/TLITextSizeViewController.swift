//
//  TLITextSizeViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLITextSizeViewController: TLIGroupedTableViewController, UIGestureRecognizerDelegate {
    let textSizeCellIdentifier = "TextSizeCellIdentifier"
    let numbers = [13, 14, 15, 16, 17, 18, 19, 20, 21]
    
    // MARK: Initializers
    
    override init() {
        super.init(style: UITableViewStyle.Grouped)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
    }
    
    required  init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Text Size"
        
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        
        self.navigationController?.interactivePopGestureRecognizer!.enabled = true
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName(TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
    }
    
    func configureCell(cell:UITableViewCell, indexPath:NSIndexPath) {
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Use System Size"
                cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 17.0)
                cell.textLabel?.textColor = UIColor.tinylogTextColor()
                
                let switchMode:UISwitch = UISwitch(frame: CGRectMake(0, 0, self.view.frame.size.width, 20.0))
                switchMode.addTarget(self, action: "toggleSystemFontSize:", forControlEvents: UIControlEvents.ValueChanged)
                switchMode.onTintColor = UIColor.tinylogMainColor()
                cell.accessoryView = switchMode
                cell.accessoryType = UITableViewCellAccessoryType.None
                
                let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                let useSystemFontSize:String = userDefaults.objectForKey("kSystemFontSize") as! String
                
                if useSystemFontSize == "on" {
                    switchMode.setOn(true, animated: false)
                } else if useSystemFontSize == "off" {
                    switchMode.setOn(false, animated: false)
                }
                
            } else if indexPath.row == 1 {
                
                let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                let size:Float = userDefaults.floatForKey("kFontSize")
                
                var defaultValue:Int = 0
                for (index, number) in numbers.enumerate() {
                    if Int(size) == number {
                        defaultValue = index
                        break
                    }
                }
                
                let stepSlider:StepSliderControl = StepSliderControl(frame: CGRectMake(10.0, 0.0, self.view.frame.size.width - 20.0, 44.0))
                stepSlider.customizeForNumberOfSteps(8)
                stepSlider.minimumValue = 0
                stepSlider.maximumValue = Float(numbers.count - 1)
                stepSlider.value = Float(defaultValue)
                stepSlider.continuous = true
                stepSlider.addTarget(self, action: "sliderValue:", forControlEvents: UIControlEvents.ValueChanged)
                cell.contentView.addSubview(stepSlider)
                
                let useSystemFontSize:String = userDefaults.objectForKey("kSystemFontSize") as! String
                
                if useSystemFontSize == "on" {
                    stepSlider.alpha = 0.5
                    stepSlider.userInteractionEnabled = false
                } else if useSystemFontSize == "off" {
                    stepSlider.alpha = 1.0
                    stepSlider.userInteractionEnabled = true
                }
            }
        }
    }
    
    func sliderValue(sender: UISlider!) {
        let slider:UISlider = sender as UISlider
        let number = numbers[Int(slider.value)]
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(Float(number), forKey: "kFontSize")
        userDefaults.synchronize()
    }
    
    // MARK: Actions
    
    func toggleSystemFontSize(sender: UISwitch) {
        let mode:UISwitch = sender as UISwitch
        let value:NSString = mode.on == true ? "on" : "off"
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(value, forKey: "kSystemFontSize")
        userDefaults.synchronize()
        
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        
        if value == "on" {
            cell?.alpha = 0.5
            cell?.userInteractionEnabled = false
        } else if value == "off" {
            cell?.alpha = 1.0
            cell?.userInteractionEnabled = true
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
        
        self.tableView.reloadData()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(), closure)
    }
    
    func close(sender:UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: textSizeCellIdentifier)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
}

