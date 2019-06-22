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
    
    class resultTests: XCTestCase {
        func testCreateSuccessType() {
            guard let success = Result<String, String>.Success(value: "a", next: "b") else {
                fatalError()
            }
            XCTAssertEqual(success.value, "a")
            XCTAssertEqual(success.next, "b")
        }
        
        func testSuccessTypeOfStringDontHaveEmpty() {
            let success = Result<String, String>.Success(value: "a", next: "")
            XCTAssertNil(success);
        }
    }
    
    class stateTests: XCTestCase {

    }
    
    class doNothingParserTests: XCTestCase {
        func testDoNothingParser() {
            let parser = DoNothingParser<String>()
            let result = parser.parse("abc")
            
            switch result {
            case let .success(s):
                XCTAssertNil(s.value)
                XCTAssertEqual(s.next, "abc")
            default:
                assertionFailure()
            }
        }
    }
    
    class anyCharTests: XCTestCase {
        func testSuccessNormal() {
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

        func testSuccessSingleChar() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct results.
            let parser = AnyChar();
            let result: Result = parser.parse("q");
            
            guard case let .success(s) = result else {
                fatalError();
            }
            
            XCTAssertEqual(s.value, "q");
            XCTAssertEqual(s.next, nil);
        }
        
        func testFailure() {
            let parser = AnyChar();
            let result = parser.parse("");
            
            guard case let .failure(f) = result else {
                fatalError();
            }
            XCTAssertEqual(f.next, nil)
        }
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
    
    func testOrSuccess() {
        let parser = SpecificChar(value: "a").or(SpecificChar(value: "b"));
        let result1 = parser.parse("abc");
        
        guard case let .success(s1) = result1 else {
            fatalError();
        }
        XCTAssertEqual(s1.value, "a");
        XCTAssertEqual(s1.next, "bc");
        
        let result2 = parser.parse("bac");
        
        guard case let .success(s2) = result2 else {
            fatalError();
        }
        XCTAssertEqual(s2.value, "b")
        XCTAssertEqual(s2.next, "ac")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
