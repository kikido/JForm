//
//  JFormTests.swift
//  JFormTests
//
//  Created by dqh on 2021/7/19.
//

import XCTest


class JFormTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("begin ")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("end")
        
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        int a = 1
//        int b = 1
        let a = 1
        XCTAssertTrue(a == 1)
        print("middle")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
