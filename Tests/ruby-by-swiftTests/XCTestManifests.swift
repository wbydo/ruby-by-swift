import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ruby_by_swiftTests.allTests),
    ]
}
#endif
