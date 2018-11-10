import XCTest
import Promise

final class PromiseTests: XCTestCase {
    func testThen() {
        var flag = false
        let future = Future.fulfilled
        
        future.then {
            XCTAssertFalse(flag)
            flag = true
        }
    }
    
    func testAsync() {
        let future = Future.fulfilled.delayed(by: 0.05)
        assertWillBeFulfilled(future)
    }

    func testThrowing() {
        let future = Future<Void> { _ in throw SimpleError() }
        assertIsRejected(future)
    }
    
    func testAsyncRejection() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.05)
        assertWillBeRejected(future)
    }
    
    func testPending() {
        let future = Future<Void>.pending
        assertWillStayPending(future)
    }
    
    func testFulfilled() {
        let (future, promise) = Future<Void>.make()
        promise.fulfill()
        assertIsFulfilled(future)
    }
    
    func testRejected() {
        let (future, promise) = Future<Void>.make()
        promise.reject(with: SimpleError())
        assertIsRejected(future)
    }
    
    func testMap() {
        let string = "someString"
        let future = Future.fulfilled(with: string)
            .map { $0.count }
            .map { $0 * 2 }
        
        assertWillBeFulfilled(future, with: string.count * 2)
    }
    
    func testFlatMap() {
        let string = "hello"
        let future1 = Future.fulfilled(with: string).delayed(by: 0.05)

        let future2 = future1.flatMap { value in
            Future.fulfilled(with: value.count).delayed(by: 0.05)
        }
        
        assertWillBeFulfilled(future2, with: string.count)
    }

    func testDoubleResolve() {
        let future = Future<Bool> { promise in
            promise.fulfill(with: true)
            promise.fulfill(with: false)
        }

        assertIsFulfilled(future, with: true)
    }
    
    func testRejectThenResolve() {
        let future = Future<Void> { promise in
            promise.reject(with: SimpleError())
            promise.fulfill()
        }
        
        assertIsRejected(future)
    }
    
    func testDoubleReject() {
        let future = Future<Void> { promise in
            promise.reject(with: SimpleError())
            promise.reject(with: SimpleError())
        }
        
        assertIsRejected(future)
    }

    func testResolveThenReject() {
        let future = Future<Void> { promise in
            promise.fulfill()
            promise.reject(with: SimpleError())
        }
        
        assertIsFulfilled(future)
    }
    
    func testZalgoContained() {
        let future = Future.fulfilled
        var called = false
        
        let wait = waitTestExpectation { fulfill in
            future.then {
                XCTAssert(called)
                fulfill()
            }
        }
        
        called = true
        wait()
    }
}
