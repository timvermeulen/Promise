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
        let promise = Promise<Void>()
        promise.fulfill()
        assertIsFulfilled(promise.future)
    }
    
    func testRejected() {
        let promise = Promise<Void>()
        promise.reject(with: SimpleError())
        assertIsRejected(promise.future)
    }
    
    func testMap() {
        let string = "someString"
        let future = Future.fulfilled(with: string)
            .map { $0.count }
            .map { $0 * 2 }
        
        assertIsFulfilled(future, with: string.count * 2)
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
        let future = Future<Bool> { resolver in
            resolver.fulfill(with: true)
            resolver.fulfill(with: false)
        }

        assertIsFulfilled(future, with: true)
    }
    
    func testRejectThenResolve() {
        let future = Future<Void> { resolver in
            resolver.reject(with: SimpleError())
            resolver.fulfill()
        }
        
        assertIsRejected(future)
    }
    
    func testDoubleReject() {
        let future = Future<Void> { resolver in
            resolver.reject(with: SimpleError())
            resolver.reject(with: SimpleError())
        }
        
        assertIsRejected(future)
    }

    func testResolveThenReject() {
        let future = Future<Void> { resolver in
            resolver.fulfill()
            resolver.reject(with: SimpleError())
        }
        
        assertIsFulfilled(future)
    }
}
