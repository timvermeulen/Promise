import XCTest
import Promise

private let defaultTimeout: TimeInterval = 1

private extension BasicFuture {
    var value: Value? {
        var value: Value?
        then { value = $0 }
        return value
    }
}

private extension Future {
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
}

extension XCTestCase {
    func testExpectation(timeout: TimeInterval = defaultTimeout, isInverted: Bool = false, block: (_ fulfill: @escaping () -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: "")
        expectation.isInverted = isInverted
        try block { [weak expectation] in expectation?.fulfill() }
        wait(for: [expectation], timeout: timeout)
    }
    
    func testValue<Value>(of future: BasicFuture<Value>, timeout: TimeInterval = defaultTimeout, _ block: @escaping (Value) -> Void) {
        testExpectation(timeout: timeout) { fulfill in
            future.then { value in
                block(value)
                fulfill()
            }
        }
    }
    
    func testValue<Value>(of future: Future<Value>, timeout: TimeInterval = defaultTimeout, file: StaticString = #file, line: UInt = #line, _ block: @escaping (Value) -> Void) {
        future.catch { _ in
            XCTFail(file: file, line: line)
        }
        
        testExpectation(timeout: timeout) { fulfill in
            future.then { value in
                block(value)
                fulfill()
            }
        }
    }
    
    func testError<Value>(of future: Future<Value>, timeout: TimeInterval = defaultTimeout, file: StaticString = #file, line: UInt = #line, _ block: @escaping (Error) -> Void) {
        future.then { _ in
            XCTFail(file: file, line: line)
        }
        
        testExpectation(timeout: timeout) { fulfill in
            future.catch { error in
                block(error)
                fulfill()
            }
        }
    }
    
    func testCurrentValue<Value>(of future: BasicFuture<Value>, file: StaticString = #file, line: UInt = #line, _ block: (Value) -> Void) {
        assertIsFulfilled(future, file: file, line: line)
        
        if let value = future.value {
            block(value)
        }
    }
    
    func testCurrentValue<Value>(of future: Future<Value>, file: StaticString = #file, line: UInt = #line, _ block: (Value) -> Void) {
        assertIsFulfilled(future, file: file, line: line)
        
        if let value = future.value {
            block(value)
        }
    }
    
    func testCurrentError<Value>(of future: Future<Value>, file: StaticString = #file, line: UInt = #line, _ block: (Error) -> Void) {
        assertIsRejected(future, file: file, line: line)
        
        if let error = future.error {
            block(error)
        }
    }
    
    func assertWillBeFulfilled<Value>(_ future: BasicFuture<Value>, timeout: TimeInterval = defaultTimeout) {
        testValue(of: future, timeout: timeout) { _ in }
    }
    
    func assertWillBeFulfilled<Value>(_ future: Future<Value>, timeout: TimeInterval = defaultTimeout) {
        testValue(of: future, timeout: timeout) { _ in }
    }
    
    func assertWillBeFulfilled<Value: Equatable>(_ future: BasicFuture<Value>, with expectedValue: Value, timeout: TimeInterval = defaultTimeout, file: StaticString = #file, line: UInt = #line) {
        testValue(of: future, timeout: timeout) { value in
            XCTAssertEqual(value, expectedValue, file: file, line: line)
        }
    }
    
    func assertWillBeFulfilled<Value: Equatable>(_ future: Future<Value>, with expectedValue: Value, timeout: TimeInterval = defaultTimeout, file: StaticString = #file, line: UInt = #line) {
        testValue(of: future, timeout: timeout) { value in
            XCTAssertEqual(value, expectedValue, file: file, line: line)
        }
    }
    
    func assertWillBeRejected<Value>(_ future: Future<Value>, timeout: TimeInterval = defaultTimeout, file: StaticString = #file, line: UInt = #line) {
        testError(of: future, timeout: timeout, file: file, line: line) { _ in }
    }
    
    func assertWillBeRejected<Value, Error: Swift.Error & Equatable>(_ future: Future<Value>, with expectedError: Error, timeout: TimeInterval = defaultTimeout, file: StaticString = #file, line: UInt = #line) {
        testError(of: future, timeout: timeout, file: file, line: line) { error in
            XCTAssertEqual(error as? Error, expectedError, file: file, line: line)
        }
    }
    
    func assertWillStayPending<Value>(_ future: BasicFuture<Value>, timeout: TimeInterval = defaultTimeout, file: StaticString = #file, line: UInt = #line) {
        testExpectation(isInverted: true) { reject in
            future.then { _ in reject() }
        }
    }
    
    func assertWillStayPending<Value>(_ future: Future<Value>, timeout: TimeInterval = defaultTimeout, file: StaticString = #file, line: UInt = #line) {
        testExpectation(isInverted: true) { reject in
            future.always(reject)
        }
    }
    
    func assertIsPending<Value>(_ future: BasicFuture<Value>, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(future.value, file: file, line: line)
    }
    
    func assertIsFulfilled<Value>(_ future: BasicFuture<Value>, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(future.value, file: file, line: line)
    }
    
    func assertIsFulfilled<Value: Equatable>(_ future: BasicFuture<Value>, with expectedValue: Value, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(future.value, expectedValue, file: file, line: line)
    }
    
    func assertIsPending<Value>(_ future: Future<Value>, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(future.value, file: file, line: line)
        XCTAssertNil(future.error, file: file, line: line)
    }
    
    func assertIsFulfilled<Value>(_ future: Future<Value>, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(future.value, file: file, line: line)
        XCTAssertNil(future.error, file: file, line: line)
    }
    
    func assertIsFulfilled<Value: Equatable>(_ future: Future<Value>, with expectedValue: Value, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(future.value, expectedValue, file: file, line: line)
        XCTAssertNil(future.error, file: file, line: line)
    }
    
    func assertIsRejected<Value>(_ future: Future<Value>, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(future.value, file: file, line: line)
        XCTAssertNotNil(future.error, file: file, line: line)
    }
    
    func assertIsRejected<Value, Error: Swift.Error & Equatable>(_ future: Future<Value>, with expectedError: Error, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(future.value, file: file, line: line)
        XCTAssertEqual(future.error as? Error, expectedError, file: file, line: line)
    }
}

struct SimpleError: Error, Equatable {}
