//
//  parserTests.swift
//  ruby-by-swiftTests
//
//  Created by hbk on 2019/06/17.
//

import XCTest

class parserTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAnyChar() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let parser = AnyChar();
        let result: Result = parser.parse("abc");
        
        guard case let .success(s) = result else {
            fatalError();
        }

        XCTAssertEqual(s.value, "a");
        XCTAssertEqual(s.next, "bc");

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
