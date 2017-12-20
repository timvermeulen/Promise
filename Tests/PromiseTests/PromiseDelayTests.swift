import XCTest
import Promise

final class PromiseDelayTests: XCTestCase {
    func testDelay() {
        let promise = FailablePromise.fulfilled.delayed(by: 0.5)
        assertPromiseIsPending(promise)
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testTimeout() {
        let promise = FailablePromise<Void>.pending.timedOut(after: 0.5, withError: SimpleError())
        assertPromiseIsPending(promise)
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testTimeoutFunctionSucceeds() {
        let promise = FailablePromise.fulfilled.delayed(by: 0.5)
        let withTimeout = promise.timedOut(after: 1.5, withError: SimpleError())
        
        assertPromiseIsPending(promise)
        
        testExpectation { fulfillExpectation in
            withTimeout.then {
                fulfillExpectation()
            }
        }
    }
    
    
    func testTimeoutFunctionFails() {
        let promise = FailablePromise.fulfilled.delayed(by: 1)
        let withTimeout = promise.timedOut(after: 0.5, withError: SimpleError())
        
        assertPromiseIsPending(withTimeout)
        
        testExpectation { fulfillExpectation in
            withTimeout.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
