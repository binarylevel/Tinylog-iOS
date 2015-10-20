//
//  TLISettingsFontPickerViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLISettingsFontPickerViewController: TLIGroupedTableViewController {
    
    var currentIndexPath:NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Font"
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        
        let selectedKey:NSString? = TLISettingsFontPickerViewController.selectedKey()!
        
        if selectedKey != nil {
            self.currentIndexPath = NSIndexPath(forRow: self.keys()!.indexOfObject(selectedKey!), inSection: 0)
            self.tableView.reloadData()
            self.tableView.scrollToRowAtIndexPath(self.currentIndexPath!, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        }
    }
    
    struct FontKeys {
        static var kTLIFontDefaultsKey: NSString = "TLIFontDefaults"
        static var kTLIFontSFDefaultsKey: NSString = ".SFUIText-Regular"
        static var kTLIFontHelveticaNeueDefaultsKey: NSString = "HelveticaNeue"
        static var kTLIFontAvenirDefaultsKey: NSString = "Avenir"
        static var kTLIFontHoeflerDefaultsKey: NSString = "Hoefler"
        static var kTLIFontCourierDefaultsKey: NSString = "Courier"
        static var kTLIFontGeorgiaDefaultsKey: NSString = "Georgia"
        static var kTLIFontMenloDefaultsKey: NSString = "Menlo"
        static var kTLIFontTimesNewRomanDefaultsKey: NSString = "TimesNewRoman"
        static var kTLIFontPalatinoDefaultsKey: NSString = "Palatino"
        static var kTLIFontIowanDefaultsKey: NSString = "Iowan"
    }
    
    //TODO make large. medium, small
    class func fontSizeAdjustment()->CGFloat {
        return 0.0
    }
    
    class func defaultsKey()->NSString? {
        return FontKeys.kTLIFontDefaultsKey
    }
    
    class func valueMap()->NSDictionary? {
        var map:NSDictionary? = nil
        var onceToken:dispatch_once_t = 0
        dispatch_once(&onceToken) { () -> Void in
            
            if #available(iOS 9, *) {
                map = NSDictionary(objects: [
                    "SF",
                    "Helvetica Neue",
                    "Avenir",
                    "Hoefler",
                    "Courier",
                    "Georgia",
                    "Menlo",
                    "Times New Roman",
                    "Palatino",
                    "Iowan Old Style"], forKeys: [
                        FontKeys.kTLIFontSFDefaultsKey,
                        FontKeys.kTLIFontHelveticaNeueDefaultsKey,
                        FontKeys.kTLIFontAvenirDefaultsKey,
                        FontKeys.kTLIFontHoeflerDefaultsKey,
                        FontKeys.kTLIFontCourierDefaultsKey,
                        FontKeys.kTLIFontGeorgiaDefaultsKey,
                        FontKeys.kTLIFontMenloDefaultsKey,
                        FontKeys.kTLIFontTimesNewRomanDefaultsKey,
                        FontKeys.kTLIFontPalatinoDefaultsKey,
                        FontKeys.kTLIFontIowanDefaultsKey])
            } else {
                map = NSDictionary(objects: [
                    "Helvetica Neue",
                    "Avenir",
                    "Hoefler",
                    "Courier",
                    "Georgia",
                    "Menlo",
                    "Times New Roman",
                    "Palatino",
                    "Iowan Old Style"], forKeys: [
                        FontKeys.kTLIFontHelveticaNeueDefaultsKey,
                        FontKeys.kTLIFontAvenirDefaultsKey,
                        FontKeys.kTLIFontHoeflerDefaultsKey,
                        FontKeys.kTLIFontCourierDefaultsKey,
                        FontKeys.kTLIFontGeorgiaDefaultsKey,
                        FontKeys.kTLIFontMenloDefaultsKey,
                        FontKeys.kTLIFontTimesNewRomanDefaultsKey,
                        FontKeys.kTLIFontPalatinoDefaultsKey,
                        FontKeys.kTLIFontIowanDefaultsKey])
            }
        }
        return map
    }
    
    func keys()->NSArray? {
        
        if #available(iOS 9, *) {
            let arr = NSArray(objects: FontKeys.kTLIFontSFDefaultsKey, FontKeys.kTLIFontHelveticaNeueDefaultsKey, FontKeys.kTLIFontAvenirDefaultsKey, FontKeys.kTLIFontHoeflerDefaultsKey, FontKeys.kTLIFontCourierDefaultsKey, FontKeys.kTLIFontGeorgiaDefaultsKey, FontKeys.kTLIFontMenloDefaultsKey, FontKeys.kTLIFontTimesNewRomanDefaultsKey, FontKeys.kTLIFontPalatinoDefaultsKey, FontKeys.kTLIFontIowanDefaultsKey)
            let sortedArray = arr.sortedArrayUsingSelector("localizedCaseInsensitiveCompare:")
            return sortedArray
        } else {
            let arr = NSArray(objects: FontKeys.kTLIFontHelveticaNeueDefaultsKey, FontKeys.kTLIFontAvenirDefaultsKey, FontKeys.kTLIFontHoeflerDefaultsKey, FontKeys.kTLIFontCourierDefaultsKey, FontKeys.kTLIFontGeorgiaDefaultsKey, FontKeys.kTLIFontMenloDefaultsKey, FontKeys.kTLIFontTimesNewRomanDefaultsKey, FontKeys.kTLIFontPalatinoDefaultsKey, FontKeys.kTLIFontIowanDefaultsKey)
            let sortedArray = arr.sortedArrayUsingSelector("localizedCaseInsensitiveCompare:")
            return sortedArray
        }
    }
    
    class func selectedKey()->NSString? {
        return NSUserDefaults.standardUserDefaults().stringForKey(defaultsKey()! as String)
    }
    
    class func setSelectedKey(key:NSString) {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(key, forKey: defaultsKey()! as String)
        userDefaults.synchronize()
    }
    
    func cellTextForKey(key:AnyObject)->NSString? {
        return TLISettingsFontPickerViewController.textForKey(key as! NSString)
    }
    
    func cellImageForKey(key:AnyObject)->UIImage? {
        return nil
    }
    
    class func textForKey(key:NSString)->NSString? {
        return valueMap()?.objectForKey(key) as? NSString
    }
    
    class func textForSelectedKey()->NSString? {
        return textForKey(selectedKey()!)!
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys()!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TLIGroupedTableViewCell = TLIGroupedTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CellIdentifier")
        let key:NSString = self.keys()!.objectAtIndex(indexPath.row) as! NSString
        let selectedKey = TLISettingsFontPickerViewController.selectedKey()!
        cell.textLabel!.text = self.cellTextForKey(key) as? String
        cell.tintColor = UIColor.tinylogMainColor()
        
        if key as NSString == selectedKey {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        cell.textLabel!.font = UIFont.tinylogFontOfSize(18.0, key: key)!
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        currentIndexPath = indexPath
        
        TLISettingsFontPickerViewController.setSelectedKey(self.keys()!.objectAtIndex(indexPath.row) as! NSString)
        self.navigationController?.popViewControllerAnimated(true)
        
        NSNotificationCenter.defaultCenter().postNotificationName(TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
    }
}
