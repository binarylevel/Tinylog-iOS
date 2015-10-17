//
//  TLISetupViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 17/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit
import PureLayout
import SVProgressHUD

class TLISetupViewController: UIViewController {
    
    var didSetupConstraints = false
    
    lazy var subtitleLabel:UILabel? = {
        let subtitleLabel:UILabel = UILabel.newAutoLayoutView()
        subtitleLabel.lineBreakMode = .ByTruncatingTail
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textAlignment = .Center
        subtitleLabel.textColor = UIColor.tinylogMainColor()
        subtitleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 34.0)
        subtitleLabel.text = "iCloud for Tinylog"
        return subtitleLabel
    }()
    
    lazy var descriptionLabel:UILabel? = {
        let descriptionLabel:UILabel = UILabel.newAutoLayoutView()
        descriptionLabel.lineBreakMode = .ByTruncatingTail
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textAlignment = .Center
        descriptionLabel.textColor = UIColor.tinylogMainColor()
        descriptionLabel.font = UIFont(name: "HelveticaNeue", size: 28.0)
        descriptionLabel.text = "iCloud keeps your lists up to date on your iPhone and iPad."
        return descriptionLabel
    }()
    
    lazy var notNowButton:TLIRoundedButton? = {
        let notNowButton = TLIRoundedButton()
        notNowButton.setTitle("Later", forState: UIControlState.Normal)
        notNowButton.backgroundColor = UIColor.tinylogTextColor()
        notNowButton.addTarget(self, action: "disableiCloudAndDismiss:", forControlEvents: UIControlEvents.TouchDown)
        return notNowButton
    }()
    
    lazy var useiCloudButton:TLIRoundedButton? = {
        let useiCloudButton = TLIRoundedButton()
        useiCloudButton.setTitle("Use iCloud", forState: UIControlState.Normal)
        useiCloudButton.addTarget(self, action: "enableiCloudAndDismiss:", forControlEvents: UIControlEvents.TouchDown)
        useiCloudButton.backgroundColor = UIColor.tinylogMainColor()
        return useiCloudButton
    }()
    
    lazy var cloudImageView:UIImageView? = {
        let cloudImageView = UIImageView(image: UIImage(named: "cloud"))
        cloudImageView.translatesAutoresizingMaskIntoConstraints = false
        return cloudImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.view.backgroundColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }
    
    override func loadView() {
        super.loadView()
        self.view = UIView()
        self.view.addSubview(cloudImageView!)
        self.view.addSubview(notNowButton!)
        self.view.addSubview(useiCloudButton!)
        self.view.addSubview(subtitleLabel!)
        self.view.addSubview(descriptionLabel!)
        self.view.setNeedsUpdateConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        notNowButton!.frame = CGRectMake(0.0, self.view.frame.size.height - 55.0, self.view.frame.size.width / 2.0, 55.0)
        useiCloudButton!.frame = CGRectMake(notNowButton!.frame.origin.x + notNowButton!.frame.size.width, self.view.frame.size.height - 55.0, self.view.frame.size.width / 2.0, 55.0)
    }
    
    override func updateViewConstraints() {
        
        if !didSetupConstraints {
            
            cloudImageView!.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: self.view, withOffset: -90.0)
            cloudImageView!.autoAlignAxis(ALAxis.Vertical, toSameAxisOfView: self.view, withOffset: 0.0)
            
            subtitleLabel!.autoPinEdgeToSuperviewEdge(.Leading, withInset: 20.0)
            subtitleLabel!.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 20.0)
            subtitleLabel!.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: cloudImageView!, withOffset: 20.0)
            
            descriptionLabel!.autoPinEdgeToSuperviewEdge(.Leading, withInset: 20.0)
            descriptionLabel!.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 20.0)
            descriptionLabel!.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: subtitleLabel!, withOffset: 20.0)
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    func enableiCloudAndDismiss(button:TLIRoundedButton) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("off", forKey: "kSetupScreen")
        userDefaults.setObject("on", forKey: TLIUserDefaults.kTLISyncMode as String)
        userDefaults.synchronize()
        let syncManager = TLISyncManager.sharedSyncManager()
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
        self.dismissViewControllerAnimated(true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Enable iCloud", properties: nil)
    }
    
    func disableiCloudAndDismiss(button:TLIRoundedButton) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject("off", forKey: "kSetupScreen")
        userDefaults.setObject("off", forKey: TLIUserDefaults.kTLISyncMode as String)
        userDefaults.synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
        TLIAnalyticsTracker.trackMixpanelEvent("Disable iCloud", properties: nil)
    }
}

