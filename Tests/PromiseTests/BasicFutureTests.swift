import XCTest
import Promise

final class BasicFutureTests: XCTestCase {
    func testThenFulfilled() {
        let future = BasicFuture.fulfilled
        assertIsFulfilled(future)
    }
    
    func testThenImmediateFulfill() {
        let (future, promise) = BasicFuture<Void>.make()
        assertIsPending(future)
        promise.fulfill()
        assertIsFulfilled(future)
    }
    
    func testThenDelayedFulfill() {
        let (future, promise) = BasicFuture<Void>.make()
        wait(0.01)
        promise.fulfill()
        assertIsFulfilled(future)
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
