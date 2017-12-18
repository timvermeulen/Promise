import XCTest
@testable import Promise

extension XCTestCase {
    func testExpectation(description: String = #function, timeout: TimeInterval = 1, block: (_ fulfill: @escaping () -> Void) throws -> Void) rethrows {
        let expectation = self.expectation(description: description)
        try block { [weak expectation] in expectation?.fulfill() }
        self.wait(for: [expectation], timeout: timeout)
    }
    
    func assertPromiseIsPending<Value>(_ promise: FailablePromise<Value>, file: StaticString = #file, line: UInt = #line) {
        var flag = false
        
        testExpectation { fulfillExpectation in
            promise.always {
                XCTAssert(flag, file: file, line: line)
            }
            
            delay(0.1) {
                flag = true
                fulfillExpectation()
            }
        }
    }
}

func delay(_ duration: TimeInterval, block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        block()
    }
}

struct SimpleError: Error {}
