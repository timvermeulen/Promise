import XCTest
import Promise

final class PromiseDelayTests: XCTestCase {
    func testDelay() {
        let future = Future.fulfilled.delayed(by: 0.5)
        assertIsPending(future)
        assertWillBeFulfilled(future)
    }
    
    func testTimeout() {
        let future = Future<Void>.pending.timedOut(after: 0.5, withError: SimpleError())
        assertIsPending(future)
        assertWillBeRejected(future)
    }
    
    func testTimeoutFunctionSucceeds() {
        let future = Future.fulfilled.delayed(by: 0.5).timedOut(after: 1.5, withError: SimpleError())
        assertIsPending(future)
        assertWillBeFulfilled(future)
    }
    
    
    func testTimeoutFunctionFails() {
        let future = Future<Void>.pending.timedOut(after: 0.5, withError: SimpleError())
        assertIsPending(future)
        assertWillBeRejected(future)
    }
}
