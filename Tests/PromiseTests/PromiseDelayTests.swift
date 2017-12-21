import XCTest
import Promise

final class PromiseDelayTests: XCTestCase {
    func testDelay() {
        let promise = FailablePromise.fulfilled.delayed(by: 0.5)
        promise.assertIsPending()
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testTimeout() {
        let promise = FailablePromise<Void>.pending.timedOut(after: 0.5, withError: SimpleError())
        promise.assertIsPending()
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testTimeoutFunctionSucceeds() {
        let promise = FailablePromise.fulfilled.delayed(by: 0.5)
        let withTimeout = promise.timedOut(after: 1.5, withError: SimpleError())
        
        promise.assertIsPending()
        
        testExpectation { fulfillExpectation in
            withTimeout.then {
                fulfillExpectation()
            }
        }
    }
    
    
    func testTimeoutFunctionFails() {
        let promise = FailablePromise.fulfilled.delayed(by: 1)
        let withTimeout = promise.timedOut(after: 0.5, withError: SimpleError())
        
        withTimeout.assertIsPending()
        
        testExpectation { fulfillExpectation in
            withTimeout.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
