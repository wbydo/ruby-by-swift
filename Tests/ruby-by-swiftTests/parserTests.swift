//
//  parserTests.swift
//  ruby-by-swiftTests
//
//  Created by wbydo on 2019/06/17.
//

import XCTest

class parserTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAnyCharSuccess() {
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
    
    func testAnyCharFailure() {
        let parser = AnyChar();
        let result = parser.parse("");
        
        guard case let .failure(f) = result else {
            fatalError();
        }
        XCTAssertEqual(f.next, nil)
    }
    
    func testSpecificCharSuccess() {
        let parser = SpecificChar(value: "a");
        let result = parser.parse("abc");
        
        guard case let .success(s) = result else {
            fatalError();
        }
        XCTAssertEqual(s.value, "a")
        XCTAssertEqual(s.next, "bc")
    }
    
    func testSpecificCharFailure() {
        let parser = SpecificChar(value: "b");
        let result = parser.parse("abc");
        
        guard case let .failure(s) = result else {
            fatalError();
        }
        
        guard let next = s.next else {
            fatalError();
        }

        XCTAssertEqual(next, "abc")
    }
    
    func testSpecificCharFailureByBlank() {
        let parser = SpecificChar(value: "a");
        let result = parser.parse("");
        
        guard case let .failure(f) = result else {
            fatalError();
        }
        XCTAssertEqual(f.next, nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
