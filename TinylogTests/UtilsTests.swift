//
//  UtilsTests.swift
//  Tinylog
//
//  Created by Spiros Gerokostas on 22/10/15.
//  Copyright © 2015 Spiros Gerokostas. All rights reserved.
//

import Foundation

import XCTest
@testable import Tinylog


class UtilsTests: XCTestCase {
    
    func testDelayExample() {
        let expectation = expectationWithDescription("testDelayExample")
        
        $.delay(1.0) { () -> () in
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
