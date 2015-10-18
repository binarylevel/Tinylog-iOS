//
//  TLIMenuColorsView.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 18/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import UIKit

class TLIMenuColorsView: UIView {
    
    var colors = ["#6a6de2", "#008efe", "#fe4565", "#ffa600", "#50de72", "#ffd401"]
    var buttonsContainer:UIView?
    var tagOffset:Int
    var radius:CGFloat = 40.0
    var selectedIndex:Int?
    var currentColor:String?
    
    func findIndexByColor(color:String)->Int {
        switch color {
        case "#6a6de2":
            return 0
        case "#008efe":
            return 1
        case "#fe4565":
            return 2
        case "#ffa600":
            return 3
        case "#50de72":
            return 4
        case "#ffd401":
            return 5
        default:
            return -1
        }
    }
    
    override init(frame: CGRect) {
        tagOffset = 1000
        super.init(frame: frame)
        selectedIndex = 0
        currentColor = colors[0]
        addButtons()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addButtons() {
        buttonsContainer = UIView(frame: CGRectMake(0.0, 0.0, self.frame.size.width, 51.0))
        self.addSubview(buttonsContainer!)
        var index:Int = 0;
        
        for item in colors {
            let button:TLICircleButton = TLICircleButton(frame: CGRectMake(0.0, 0.0, radius, radius))
            button.tag = tagOffset + index
            button.backgroundColor = UIColor(rgba: item)
            button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchDown)
            buttonsContainer?.addSubview(button)
            index++
        }
        
        setSelectedIndex(0)
    }
    
    func selectButton(button:UIButton) {
        button.layer.borderWidth = 2.0
    }
    
    func deselectButton(button:UIButton) {
        button.layer.borderWidth = 0.0
    }
    
    func setSelectedIndex(newSelectedIndex:Int) {
        
        if selectedIndex != NSNotFound {
            let fromButton:UIButton = buttonsContainer!.viewWithTag(tagOffset + selectedIndex!) as! UIButton
            deselectButton(fromButton)
        }
        
        //let oldSelectedIndex:Int = selectedIndex!
        selectedIndex = newSelectedIndex
        
        var toButton:UIButton
        
        if selectedIndex != NSNotFound {
            toButton = buttonsContainer!.viewWithTag(tagOffset + selectedIndex!) as! UIButton
            selectButton(toButton)
        }
    }
    
    func buttonPressed(button:UIButton) {
        currentColor = colors[button.tag - tagOffset]
        setSelectedIndex(button.tag - tagOffset)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutButtons()
    }
    
    func layoutButtons() {
        var index:Int = 0
        //let count:Int = buttonsContainer!.subviews.count
        let buttons:NSArray = buttonsContainer!.subviews as NSArray
        var rect:CGRect = CGRectMake(0.0, 0.0, radius, radius)
        for item in buttons {
            let button:UIButton = item as! UIButton
            button.frame = rect
            rect.origin.x += rect.size.width + 10.0
            index++
        }
    }
}

