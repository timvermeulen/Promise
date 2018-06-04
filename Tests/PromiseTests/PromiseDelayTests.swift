import XCTest
import Promise

final class PromiseDelayTests: XCTestCase {
    func testDelay() {
        let future = Future.fulfilled.delayed(by: 0.5)
        future.assertIsPending()
        
        testExpectation { fulfill in
            future.then {
                fulfill()
            }
        }
    }
    
    func testTimeout() {
        let future = Future<Void>.pending.timedOut(after: 0.5, withError: SimpleError())
        future.assertIsPending()
        
        testExpectation { fulfill in
            future.catch { _ in
                fulfill()
            }
        }
    }
    
    func testTimeoutFunctionSucceeds() {
        let future = Future.fulfilled.delayed(by: 0.5)
        let withTimeout = future.timedOut(after: 1.5, withError: SimpleError())
        
        future.assertIsPending()
        
        testExpectation { fulfill in
            withTimeout.then {
                fulfill()
            }
        }
    }
    
    
    func testTimeoutFunctionFails() {
        let future = Future<Void>.pending.timedOut(after: 0.5, withError: SimpleError())
        
        future.assertIsPending()
        
        testExpectation { fulfill in
            future.catch { _ in
                fulfill()
            }
        }
    }
}
