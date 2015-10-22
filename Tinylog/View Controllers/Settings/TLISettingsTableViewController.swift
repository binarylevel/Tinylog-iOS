//
//  TLISettingsTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import MessageUI
import SVProgressHUD

class TLISettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate {
    
    let settingsCellIdentifier = "SettingsCellIdentifier"
    
    // MARK: Initializers
        
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Grouped)
    }
    
    required  init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "close:")
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        self.tableView?.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        
        self.title = "Settings"
        
        self.navigationController?.interactivePopGestureRecognizer!.enabled = true
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFonts", name: TLINotifications.kTLIFontDidChangeNotification as String, object: nil)
    }
    
    func updateFonts() {
        self.navigationController?.navigationBar.setNeedsDisplay()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configureCell(cell:UITableViewCell, indexPath:NSIndexPath) {
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.textLabel?.font = UIFont.systemFontOfSize(17.0)
        cell.textLabel?.textColor = UIColor.tinylogTextColor()
        
        let selectedBackgroundView = UIView(frame: cell.frame)
        selectedBackgroundView.backgroundColor = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        selectedBackgroundView.contentMode = UIViewContentMode.Redraw
        cell.selectedBackgroundView = selectedBackgroundView
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "iCloud"
                cell.imageView?.image = UIImage(named: "706-cloud")
                let switchMode:UISwitch = UISwitch(frame: CGRectMake(0, 0, self.view.frame.size.width, 20.0))
                switchMode.addTarget(self, action: "toggleSyncSettings:", forControlEvents: UIControlEvents.ValueChanged)
                switchMode.onTintColor = UIColor.tinylogMainColor()
                cell.accessoryView = switchMode
                cell.accessoryType = UITableViewCellAccessoryType.None
                
                let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                let syncModeValue:String = userDefaults.objectForKey(TLIUserDefaults.kTLISyncMode as String) as! String
                
                if syncModeValue == "on" {
                    switchMode.setOn(true, animated: false)
                } else if syncModeValue == "off" {
                    switchMode.setOn(false, animated: false)
                }
                
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Font"
                cell.detailTextLabel?.text = TLISettingsFontPickerViewController.textForSelectedKey() as? String
                cell.detailTextLabel?.font = UIFont.tinylogFontOfSize(16.0, key: TLISettingsFontPickerViewController.selectedKey()!)
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Text Size"
                cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue", size: 16.0)
                let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                let useSystemFontSize:String = userDefaults.objectForKey("kSystemFontSize") as! String
                
                if useSystemFontSize == "on" {
                    cell.detailTextLabel?.text = "System Size"
                } else {
                    let fontSize:Float = userDefaults.floatForKey("kFontSize")
                    let strFontSize = NSString(format: "%.f", fontSize)
                    cell.detailTextLabel?.text = strFontSize as String
                }
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Send Feedback"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Rate Tinylog"
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Help"
            }
        } else if indexPath.section == 3 {
            cell.textLabel?.text = "About"
        }
    }
    
    // MARK: Actions
    
    func toggleSyncSettings(sender: UISwitch) {
        let mode:UISwitch = sender as UISwitch
        let value:NSString = mode.on == true ? "on" : "off"
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(value, forKey: TLIUserDefaults.kTLISyncMode as String)
        userDefaults.synchronize()
        
        $.delay(0.2, closure: { () -> () in
            let syncManager = TLISyncManager.sharedSyncManager()
            
            if value == "on" {
                syncManager.connectToSyncService(IDMICloudService, withCompletion: { (error) -> Void in
                    if error != nil {
                        if error.code == 1003 {
                            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
                            SVProgressHUD.setBackgroundColor(UIColor.tinylogMainColor())
                            SVProgressHUD.setForegroundColor(UIColor.whiteColor())
                            SVProgressHUD.setFont(UIFont(name: "HelveticaNeue", size: 14.0))
                            SVProgressHUD.showErrorWithStatus("You are not logged in to iCloud.Tap Settings > iCloud to login.")
                        }
                    }
                })
            } else if value == "off" {
                if syncManager.canSynchronize() {
                    syncManager.disconnectFromSyncServiceWithCompletion({ () -> Void in
                    })
                }
            }
        })
    }
    
    func close(sender:UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font = UIFont.regularFontWithSize(16.0)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "SYNC"
        } else if section == 1 {
            return "DISPLAY"
        } else if section == 2 {
            return "FEEDBACK"
        } else if section == 3 {
            return ""
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 3
        } else if section == 3 {
            return 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: settingsCellIdentifier)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController:UIViewController? = nil
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                viewController = TLISettingsFontPickerViewController()
            } else if indexPath.row == 1 {
                viewController = TLITextSizeViewController()
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if MFMailComposeViewController.canSendMail() {
                    let infoDictionary:NSDictionary = NSBundle.mainBundle().infoDictionary!
                    let version:NSString = infoDictionary.objectForKey("CFBundleShortVersionString") as! NSString
                    let build:NSString = infoDictionary.objectForKey("CFBundleVersion") as! NSString
                    let deviceModel = TLIDeviceInfo.model()
                    
                    let mailer:MFMailComposeViewController = MFMailComposeViewController()
                    mailer.mailComposeDelegate = self
                    mailer.setSubject("Tinylog \(version)")
                    mailer.setToRecipients(["feedback@tinylogapp.com"])
                    
                    let systemVersion = UIDevice.currentDevice().systemVersion
                    let stringBody = "---\nApp: Tinylog \(version) (\(build))\nDevice: \(deviceModel) (\(systemVersion))"
                    
                    mailer.setMessageBody(stringBody, isHTML: false)
                    let titleTextDict:NSDictionary = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.mediumFontWithSize(16.0)]
                    
                    mailer.navigationBar.titleTextAttributes = titleTextDict as? [String : AnyObject]
                    
                    mailer.navigationBar.tintColor = UIColor.tinylogMainColor()
                    self.presentViewController(mailer, animated: true, completion: nil)
                    mailer.viewControllers.last?.navigationItem.title = "Tinylog"
                } else {
                    let alert:UIAlertView = UIAlertView(title: "Tinylog", message: "Your device doesn't support this feature", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            } else if indexPath.row == 1 {
                let path: NSURL = NSURL(string: "https://itunes.apple.com/gr/app/tinylog/id799267191?mt=8")!
                UIApplication.sharedApplication().openURL(path)
            } else if indexPath.row == 2 {
                viewController = TLIHelpTableViewController()
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                viewController = TLIAboutViewController()
            }
        }
        if viewController != nil {
            self.navigationController?.pushViewController(viewController!
                , animated: true)
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            break;
        case MFMailComposeResultSaved.rawValue:
            break;
        case MFMailComposeResultSent.rawValue:
            break;
        case MFMailComposeResultFailed.rawValue:
            break;
        default:
            break;
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
}

