import XCTest
import Promise

final class PromiseDelayTests: XCTestCase {
    func testDelay() {
        let future = Future.fulfilled.delayed(by: 0.5, on: .main)
        future.assertIsPending()
        
        testExpectation { fulfillExpectation in
            future.then {
                fulfillExpectation()
            }
        }
    }
    
    func testTimeout() {
        let future = Future<Void>.pending.timedOut(after: 0.5, withError: SimpleError(), on: .main)
        future.assertIsPending()
        
        testExpectation { fulfillExpectation in
            future.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testTimeoutFunctionSucceeds() {
        let future = Future.fulfilled.delayed(by: 0.5, on: .main)
        let withTimeout = future.timedOut(after: 1.5, withError: SimpleError(), on: .main)
        
        future.assertIsPending()
        
        testExpectation { fulfillExpectation in
            withTimeout.then {
                fulfillExpectation()
            }
        }
    }
    
    
    func testTimeoutFunctionFails() {
        let future = Future.fulfilled.delayed(by: 1, on: .main)
        let withTimeout = future.timedOut(after: 0.5, withError: SimpleError(), on: .main)
        
        withTimeout.assertIsPending()
        
        testExpectation { fulfillExpectation in
            withTimeout.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
