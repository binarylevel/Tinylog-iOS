//
//  TLITextFieldCellDelegate.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

@objc protocol TLITextFieldCellDelegate {
    optional func shouldReturnForIndexPath(indexPath:NSIndexPath!, value:String)->Bool
    optional func updateTextLabelAtIndexPath(indexPath:NSIndexPath, value:String)
    optional func textFieldShouldBeginEditing(textField:UITextField)->Bool
    optional func textFieldShouldEndEditing(textField:UITextField)->Bool
    optional func textFieldDidBeginEditing(textField:UITextField)
    optional func textFieldDidEndEditing(textField:UITextField)
}
