import XCTest
import Promise

final class BasicFutureTests: XCTestCase {
    func testThenFulfilled() {
        let future = BasicFuture.fulfilled
        assertIsFulfilled(future)
    }
    
    func testThenImmediateFulfill() {
        let promise = BasicPromise<Void>()
        assertIsPending(promise.future)
        promise.fulfill()
        assertIsFulfilled(promise.future)
    }
    
    func testThenDelayedFulfill() {
        let promise = BasicPromise<Void>()
        wait(0.01)
        promise.fulfill()
        assertIsFulfilled(promise.future)
    }
    
    func testThenCalledOnlyOnce() {
        let future = BasicFuture.fulfilled
        var thenIsCalled = false
        
        testExpectation { fulfill in
            future.then {
                XCTAssertFalse(thenIsCalled)
                thenIsCalled = true
                fulfill()
            }
        }
        
        wait()
    }
}
