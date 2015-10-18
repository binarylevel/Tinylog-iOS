//
//  TLIAddTaskViewDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

@objc protocol TLIAddTaskViewDelegate {
    optional func addTaskViewDidBeginEditing(addTaskView:TLIAddTaskView)
    optional func addTaskViewDidEndEditing(addTaskView:TLIAddTaskView)
    optional func addTaskViewShouldHideTags(addTaskView:TLIAddTaskView)
    func addTaskView(addTaskView:TLIAddTaskView, title:NSString)
}
