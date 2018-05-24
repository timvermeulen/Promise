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
        testExpectation { fulfillExpectation in
            let future = Future.fulfilled.delayed(by: 0.05, on: .main)

            future.then {
                fulfillExpectation()
            }
        }
    }

    func testThrowing() {
        let future = Future<Void> { throw SimpleError() }
        
        testExpectation { fulfillExpectation in
            future.then {
                XCTFail()
            }
            
            future.catch { error in
                fulfillExpectation()
            }
        }
    }
    
    func testAsyncRejection() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.05, on: .main)
        
        testExpectation { fulfillExpectation in
            future.then {
                XCTFail()
            }

            future.catch { error in
                fulfillExpectation()
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
        
        testExpectation() { fulfillExpectation in
            promise.fulfill()

            promise.future.then {
                fulfillExpectation()
            }
        }
    }
    
    func testRejected() {
        let promise = Promise<Void>()

        testExpectation { fulfillExpectation in
            promise.future.catch { _ in
                fulfillExpectation()
            }

            promise.reject(with: SimpleError())
        }
    }
    
    func testMap() {
        let future = Future.fulfilled(with: "someString")
            .map { $0.count }
            .map { $0 * 2 }
        
        testExpectation() { fulfillExpectation in
            future.then { value in
                XCTAssertEqual(value, 20)
                fulfillExpectation()
            }
        }
    }
    
    func testFlatMap() {
        let future1 = Future.fulfilled(with: "hello").delayed(by: 0.05, on: .main)

        let future2 = future1.flatMap { value in
            Future.fulfilled(with: value.count).delayed(by: 0.05, on: .main)
        }

        testExpectation { fulfillExpectation in
            future2.then { value in
                XCTAssertEqual(value, 5)
                fulfillExpectation()
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
