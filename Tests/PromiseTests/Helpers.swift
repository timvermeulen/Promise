import XCTest
import Promise

private let defaultTimeout: TimeInterval = 1

extension XCTestCase {
    func testExpectation(
        timeout: TimeInterval = defaultTimeout,
        isInverted: Bool = false,
        block: (_ fulfill: @escaping () -> Void) throws -> Void
    ) rethrows {
        let expectation = self.expectation(description: "")
        expectation.isInverted = isInverted
        try block { [weak expectation] in expectation?.fulfill() }
        wait(for: [expectation], timeout: timeout)
    }
    
    func wait(_ timeout: TimeInterval = defaultTimeout) {
        testExpectation(timeout: timeout, isInverted: true) { _ in }
    }
    
    func value<Value>(of future: BasicFuture<Value>) -> Value? {
        var value: Value?
        future.then { value = $0 }
        return value
    }
    
    func value<Value>(of future: Future<Value>) -> Value? {
        var value: Value?
        future.then { value = $0 }
        return value
    }
    
    func error<Value>(of future: Future<Value>) -> Error? {
        var error: Error?
        future.catch { error = $0 }
        return error
    }
    
    func testValue<Value>(
        of future: BasicFuture<Value>,
        timeout: TimeInterval = defaultTimeout,
        _ process: @escaping (Value) -> Void
    ) {
        testExpectation(timeout: timeout) { fulfill in
            future.then { value in
                process(value)
                fulfill()
            }
        }
    }
    
    func testValue<Value>(
        of future: Future<Value>,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line,
        _ process: @escaping (Value) -> Void
    ) {
        future.catch { _ in
            XCTFail(file: file, line: line)
        }
        
        testExpectation(timeout: timeout) { fulfill in
            future.then { value in
                process(value)
                fulfill()
            }
        }
    }
    
    func testError<Value>(
        of future: Future<Value>,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line,
        _ process: @escaping (Error) -> Void
    ) {
        future.then { _ in
            XCTFail(file: file, line: line)
        }
        
        testExpectation(timeout: timeout) { fulfill in
            future.catch { error in
                process(error)
                fulfill()
            }
        }
    }
    
    func testCurrentValue<Value>(
        of future: BasicFuture<Value>,
        file: StaticString = #file,
        line: UInt = #line,
        _ process: (Value) -> Void
    ) {
        assertIsFulfilled(future, file: file, line: line)
        
        if let value = value(of: future) {
            process(value)
        }
    }
    
    func testCurrentValue<Value>(
        of future: Future<Value>,
        file: StaticString = #file,
        line: UInt = #line,
        _ process: (Value) -> Void
    ) {
        assertIsFulfilled(future, file: file, line: line)
        
        if let value = value(of: future) {
            process(value)
        }
    }
    
    func testCurrentError<Value>(
        of future: Future<Value>,
        file: StaticString = #file,
        line: UInt = #line,
        _ process: (Error) -> Void
    ) {
        assertIsRejected(future, file: file, line: line)
        
        if let error = error(of: future) {
            process(error)
        }
    }
    
    func assertWillBeFulfilled<Value>(
        _ future: BasicFuture<Value>,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertIsPending(future, file: file, line: line)
        testValue(of: future, timeout: timeout) { _ in }
    }
    
    func assertWillBeFulfilled<Value>(
        _ future: Future<Value>,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertIsPending(future, file: file, line: line)
        testValue(of: future, timeout: timeout) { _ in }
    }
    
    func assertWillBeFulfilled<Value: Equatable>(
        _ future: BasicFuture<Value>,
        with expectedValue: Value,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        testValue(of: future, timeout: timeout) { value in
            XCTAssertEqual(value, expectedValue, file: file, line: line)
        }
    }
    
    func assertWillBeFulfilled<Value: Equatable>(
        _ future: Future<Value>,
        with expectedValue: Value,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        testValue(of: future, timeout: timeout) { value in
            XCTAssertEqual(value, expectedValue, file: file, line: line)
        }
    }
    
    func assertWillBeRejected<Value>(
        _ future: Future<Value>,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertIsPending(future, file: file, line: line)
        testError(of: future, timeout: timeout, file: file, line: line) { _ in }
    }
    
    func assertWillBeRejected<Value, Error: Swift.Error & Equatable>(
        _ future: Future<Value>,
        with expectedError: Error,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertIsPending(future, file: file, line: line)
        testError(of: future, timeout: timeout, file: file, line: line) { error in
            XCTAssertEqual(error as? Error, expectedError, file: file, line: line)
        }
    }
    
    func assertWillStayPending<Value>(
        _ future: BasicFuture<Value>,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        testExpectation(isInverted: true) { reject in
            future.then { _ in reject() }
        }
    }
    
    func assertWillStayPending<Value>(
        _ future: Future<Value>,
        timeout: TimeInterval = defaultTimeout,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        testExpectation(isInverted: true) { reject in
            future.always(reject)
        }
    }
    
    func assertIsPending<Value>(
        _ future: BasicFuture<Value>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNil(value(of: future), file: file, line: line)
    }
    
    func assertIsFulfilled<Value>(
        _ future: BasicFuture<Value>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNotNil(value(of: future), file: file, line: line)
    }
    
    func assertIsFulfilled<Value: Equatable>(
        _ future: BasicFuture<Value>,
        with expectedValue: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(value(of: future), expectedValue, file: file, line: line)
    }
    
    func assertIsPending<Value>(
        _ future: Future<Value>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNil(value(of: future), file: file, line: line)
        XCTAssertNil(error(of: future), file: file, line: line)
    }
    
    func assertIsFulfilled<Value>(
        _ future: Future<Value>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNotNil(value(of: future), file: file, line: line)
        XCTAssertNil(error(of: future), file: file, line: line)
    }
    
    func assertIsFulfilled<Value: Equatable>(
        _ future: Future<Value>,
        with expectedValue: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(value(of: future), expectedValue, file: file, line: line)
        XCTAssertNil(error(of: future), file: file, line: line)
    }
    
    func assertIsRejected<Value>(
        _ future: Future<Value>,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNil(value(of: future), file: file, line: line)
        XCTAssertNotNil(error(of: future), file: file, line: line)
    }
    
    func assertIsRejected<Value, Error: Swift.Error & Equatable>(
        _ future: Future<Value>,
        with expectedError: Error,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNil(value(of: future), file: file, line: line)
        XCTAssertEqual(error(of: future) as? Error, expectedError, file: file, line: line)
    }
}

struct SimpleError: Error, Equatable {}
