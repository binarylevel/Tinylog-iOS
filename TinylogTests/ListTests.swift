//
//  ListTests.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 26/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation

import XCTest
@testable import Tinylog

class ListTests: XCTestCase {
    
    let cdc:TLICDController = TLICDController.sharedInstance
    var list:TLIList!
    
    override func setUp() {
        super.setUp()
        list = TLIList(context: cdc.context!, title: "foo", color: "#ffffff")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Initializers
    
    func testConvenienceTextAndCompleteInit() {
        let title = "foo"
        let color = "#ffffff"
        
        let list = TLIList(context: cdc.context!, title: title, color:  "#ffffff")
        
        XCTAssertEqual(list.title, title)
        XCTAssertEqual(list.color, color)
    }
    
    // MARK: isEqual(_:)
    
    func testIsEqual() {
        let listTwo = TLIList(context: cdc.context!, title: "foo", color: "#ffffff")
        
        XCTAssertFalse(list.isEqual(nil))
        XCTAssertEqual(list, list)
        XCTAssertNotEqual(list, listTwo)
    }
}
