import XCTest
import Promise

final class PromiseDelayTests: XCTestCase {
    func testDelay() {
        let future = Future.fulfilled.delayed(by: 0.5)
        assertWillBeFulfilled(future)
    }
    
    func testDelayTwice() {
        let future = Future.fulfilled.delayed(by: 0.25).delayed(by: 0.25)
        assertWillBeFulfilled(future)
    }
    
    func testDelayFromBackgroundQueue() {
        let future = Future.fulfilled.on(.global()).delayed(by: 0.5)
        assertWillBeFulfilled(future)
    }
    
    func testTimeout() {
        let future = Future<Void>.pending.timedOut(after: 0.5, withError: SimpleError())
        assertWillBeRejected(future)
    }
    
    func testTimeoutFunctionSucceeds() {
        let future = Future.fulfilled.delayed(by: 0.5).timedOut(after: 1.5, withError: SimpleError())
        assertWillBeFulfilled(future)
    }
    
    
    func testTimeoutFunctionFails() {
        let future = Future<Void>.pending.timedOut(after: 0.5, withError: SimpleError())
        assertWillBeRejected(future)
    }
}
