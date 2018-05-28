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
        
        wait(0.1)
    }
    
    func testAsync() {
        testExpectation { fulfill in
            let future = Future.fulfilled.delayed(by: 0.05)

            future.then {
                fulfill()
            }
        }
    }

    func testThrowing() {
        let future = Future<Void> { throw SimpleError() }
        
        testExpectation { fulfill in
            future.then {
                XCTFail()
            }
            
            future.catch { error in
                fulfill()
            }
        }
    }
    
    func testAsyncRejection() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.05)
        
        testExpectation { fulfill in
            future.then {
                XCTFail()
            }

            future.catch { error in
                fulfill()
            }
        }
    }
    
    func testPending() {
        let future = Future<Void>.pending
        
        future.then {
            XCTFail()
        }
        
        future.catch { _ in
            XCTFail()
        }
        
        future.always {
            XCTFail()
        }
        
        wait(0.5)
    }
    
    func testFulfilled() {
        let promise = Promise<Void>()
        
        testExpectation() { fulfill in
            promise.fulfill()

            promise.future.then {
                fulfill()
            }
        }
    }
    
    func testRejected() {
        let promise = Promise<Void>()

        testExpectation { fulfill in
            promise.future.catch { _ in
                fulfill()
            }

            promise.reject(with: SimpleError())
        }
    }
    
    func testMap() {
        let future = Future.fulfilled(with: "someString")
            .map { $0.count }
            .map { $0 * 2 }
        
        testExpectation() { fulfill in
            future.then { value in
                XCTAssertEqual(value, 20)
                fulfill()
            }
        }
    }
    
    func testFlatMap() {
        let future1 = Future.fulfilled(with: "hello").delayed(by: 0.05)

        let future2 = future1.flatMap { value in
            Future.fulfilled(with: value.count).delayed(by: 0.05)
        }

        testExpectation { fulfill in
            future2.then { value in
                XCTAssertEqual(value, 5)
                fulfill()
            }
        }
    }

    func testDoubleResolve() {
        let future = Future<Bool> { promise in
            promise.fulfill(with: true)
            promise.fulfill(with: false)
        }

        future.assertValue(true)
    }
    
    func testRejectThenResolve() {
        let future = Future<Void> { promise in
            promise.reject(with: SimpleError())
            promise.fulfill()
        }
        
        future.assertIsRejected()
    }
    
    func testDoubleReject() {
        let future = Future<Void> { promise in
            promise.reject(with: SimpleError())
            promise.reject(with: SimpleError())
        }
        
        future.assertIsRejected()
    }

    func testResolveThenReject() {
        let future = Future<Void> { promise in
            promise.fulfill()
            promise.reject(with: SimpleError())
        }
        
        future.assertIsFulfilled()
    }
}
