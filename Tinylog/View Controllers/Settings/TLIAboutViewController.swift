//
//  TLIAboutViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import MessageUI

class TLIAboutViewController: TLIGroupedTableViewController, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate {
    let aboutCellIdentifier = "AboutCellIdentifier"
    
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
        
        self.title = "About"
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
        
        cell.textLabel?.font = UIFont.tinylogFontOfSize(17.0)
        cell.textLabel?.textColor = UIColor.tinylogTextColor()
        cell.detailTextLabel?.font = UIFont.tinylogFontOfSize(15.0)
        
        let selectedBackgroundView = UIView(frame: cell.frame)
        selectedBackgroundView.backgroundColor = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
        selectedBackgroundView.contentMode = UIViewContentMode.Redraw
        cell.selectedBackgroundView = selectedBackgroundView
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Version"
                let infoDictionary:NSDictionary = NSBundle.mainBundle().infoDictionary!
                let version:NSString = infoDictionary.objectForKey("CFBundleShortVersionString") as! NSString
                cell.detailTextLabel?.text = version as String
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Web"
                cell.detailTextLabel?.text = "http://binarylevel.github.io/tinylog/"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Email"
                cell.detailTextLabel?.text = "spiros.gerokostas@gmail.com"
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Twitter"
                cell.detailTextLabel?.text = "@tinylogapp"
            }
        }
    }
    
    // MARK: Actions
    
    func close(sender:UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.frame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)
            let label = UILabel(frame: CGRectMake(17.0, 5.0, self.tableView.frame.size.width - 17.0, 44.0))
            view.addSubview(label)
            label.numberOfLines = 0
            label.font = UIFont.tinylogFontOfSize(14.0)
            label.textColor = UIColor.tinylogTextColor()
            label.text = "Logo created by John Anagnostou \n(behance.net/tzoAnagnostou)"
            label.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: "viewWebsite")
            label.addGestureRecognizer(tap)
            return view
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: aboutCellIdentifier)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let path: NSURL = NSURL(string: "http://binarylevel.github.io/tinylog/")!
                UIApplication.sharedApplication().openURL(path)
            } else if indexPath.row == 1 {
                if MFMailComposeViewController.canSendMail() {
                    let infoDictionary:NSDictionary = NSBundle.mainBundle().infoDictionary!
                    let version:NSString = infoDictionary.objectForKey("CFBundleShortVersionString") as! NSString
                    let build:NSString = infoDictionary.objectForKey("CFBundleVersion") as! NSString
                    let deviceModel = TLIDeviceInfo.model()
                    
                    let mailer:MFMailComposeViewController = MFMailComposeViewController()
                    mailer.mailComposeDelegate = self
                    mailer.setSubject("Tinylog \(version)")
                    mailer.setToRecipients(["spiros.gerokostas@gmail.com"])
                    
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
            } else if indexPath.row == 2 {
                let path: NSURL = NSURL(string: "https://twitter.com/tinylogapp")!
                UIApplication.sharedApplication().openURL(path)
            }
        }
    }
    
    func viewWebsite() {
        let path: NSURL = NSURL(string: "https://www.behance.net/tzoAnagnostou")!
        UIApplication.sharedApplication().openURL(path)
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

