//
//  StackMachineTests.swift
//  StackMachineTests
//
//  Created by Kristopher Johnson on 7/23/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

import XCTest
import StackMachine

class StackMachineTests: XCTestCase {

    var sm: StackMachine!

    override func setUp() {
        super.setUp()
        sm = StackMachine()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDepthAndDrop() throws {
        try sm.depth()
        XCTAssertEqual(try sm.top(), .int(0))
        try sm.depth()
        XCTAssertEqual(try sm.top(), .int(1))
        try sm.depth()
        XCTAssertEqual(try sm.top(), .int(2))
        try sm.drop()
        XCTAssertEqual(try sm.top(), .int(1))
        try sm.drop()
        XCTAssertEqual(try sm.top(), .int(0))
    }

    func testPush() throws {
        try sm.push(.int(123))
        XCTAssertEqual(try sm.top(), .int(123))
        try sm.depth()
        XCTAssertEqual(try sm.top(), .int(1))
    }
}
