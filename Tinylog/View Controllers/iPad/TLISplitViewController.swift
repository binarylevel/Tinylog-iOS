//
//  TLISplitViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLISplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    var listsViewController:TLIListsViewController?
    var listViewController:TLITasksViewController?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        listsViewController = TLIListsViewController()
        listViewController = TLITasksViewController()
        
        let navigationController1:UINavigationController = UINavigationController(rootViewController: listsViewController!)
        let navigationController2:UINavigationController = UINavigationController(rootViewController: listViewController!)
        
        self.viewControllers = [navigationController1, navigationController2]
        self.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func sharedSplitViewController()->TLISplitViewController {
        return TLIAppDelegate.sharedAppDelegate().window?.rootViewController as! TLISplitViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
}
