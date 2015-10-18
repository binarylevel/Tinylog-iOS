//
//  TLIGroupedTableViewController.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIGroupedTableViewController: UITableViewController {
    
    // MARK: Initializers
    
    init() {
        super.init(style: UITableViewStyle.Grouped)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
    }
    
    required  init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
