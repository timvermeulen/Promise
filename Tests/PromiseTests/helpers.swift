import XCTest
import Promise

extension XCTestCase {
    func testExpectation(description: String = #function, timeout: TimeInterval = 1, block: (_ fulfill: @escaping () -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: description)
        try block { [weak expectation] in expectation?.fulfill() }
        self.wait(for: [expectation], timeout: timeout)
    }
    
    func wait(_ duration: TimeInterval = 1) {
        testExpectation(timeout: duration + 1) { fulfill in
            delay(duration) {
                fulfill()
            }
        }
    }
}

extension Promise {
    var value: Value? {
        var value: Value?
        then { value = $0 }
        return value
    }
    
    func assertIsPending(file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(value, file: file, line: line)
    }
    
    func assertIsFulfilled(file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(value, file: file, line: line)
    }
}

extension Promise where Value: Equatable {
    func assertValue(_ value: Value, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(value, self.value, file: file, line: line)
    }
}

extension FailablePromise {
    var value: Value? {
        var value: Value?
        then { value = $0 }
        return value
    }
    
    var error: Error? {
        var error: Error?
        `catch` { error = $0 }
        return error
    }
    
    func assertIsPending(file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(value, file: file, line: line)
        XCTAssertNil(error, file: file, line: line)
    }
    
    func assertIsFulfilled(file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(value, file: file, line: line)
    }
    
    func assertIsRejected(file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(error, file: file, line: line)
    }
}

extension FailablePromise where Value: Equatable {
    func assertValue(_ value: Value, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(value, self.value, file: file, line: line)
    }
}

func delay(_ duration: TimeInterval, block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        block()
    }
}

struct SimpleError: Error {}
