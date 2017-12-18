import XCTest
import Promise

final class PromiseTests: XCTestCase {
    func testThen() {
        var flag = false
        let promise = FailablePromise.fulfilled
        
        testExpectation { fulfillExpectation in
            promise.then {
                XCTAssertFalse(flag)
                flag = true
            }
            
            promise.delayed(by: 0.1).then {
                XCTAssert(flag)
                fulfillExpectation()
            }
        }
    }
    
    func testAsync() {
        testExpectation { fulfillExpectation in
            let promise = FailablePromise.fulfilled.delayed(by: 0.05)

            promise.then {
                fulfillExpectation()
            }
        }
    }

    func testAsyncThrowing() {
        let promise = FailablePromise<Void> { _, _ in
            throw SimpleError()
        }
        
        testExpectation { fulfillExpectation in
            promise.then {
                XCTFail()
            }
            
            promise.catch { error in
                fulfillExpectation()
            }
        }
    }
    
    func testAsyncRejection() {
        let promise = FailablePromise<Void>.rejected(with: SimpleError()).delayed(by: 0.05)
        
        testExpectation { fulfillExpectation in
            promise.then {
                XCTFail()
            }

            promise.catch { error in
                fulfillExpectation()
            }
        }
    }
    
    func testThenWhenPending() {
        let promise = FailablePromise<Void>.pending
        
        testExpectation { fulfillExpectation in
            promise.then {
                XCTFail()
            }

            delay(0.05) {
                fulfillExpectation()
            }
        }
    }
    
    func testPending() {
        let promise = FailablePromise<Void>.pending
        
        testExpectation { fulfillExpectation in
            promise.then {
                XCTFail()
            }
            
            promise.catch { _ in
                XCTFail()
            }
            
            delay(0.5) {
                fulfillExpectation()
            }
        }
    }
    
    func testFulfilled() {
        let (promise, fulfill, _) = FailablePromise<Void>.makePromise()
        
        testExpectation() { fulfillExpectation in
            fulfill(())

            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testRejected() {
        let (promise, _, reject) = FailablePromise<Void>.makePromise()

        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }

            reject(SimpleError())
        }
    }
    
    func testMap() {
        let promise = FailablePromise.fulfilled(with: "someString")
            .map { $0.count }
            .map { $0 * 2 }
        
        testExpectation() { fulfillExpectation in
            promise.then { value in
                XCTAssertEqual(value, 20)
                fulfillExpectation()
            }
        }
    }
    
    func testFlatMap() {
        let promise1 = FailablePromise.fulfilled(with: "hello").delayed(by: 0.05)

        let promise2 = promise1.flatMap { value in
            FailablePromise.fulfilled(with: value.count).delayed(by: 0.05)
        }

        testExpectation { fulfillExpectation in
            promise2.then { value in
                XCTAssertEqual(value, 5)
                fulfillExpectation()
            }
        }
    }

    func testZalgoContained() {
        var flag = false

        testExpectation() { fulfillExpectation in
            FailablePromise.fulfilled.then {
                XCTAssert(flag)
                fulfillExpectation()
            }
            
            flag = true
        }
    }
    
    func testDoubleResolve() {
        let promise = FailablePromise<Bool> { fulfill, _ in
            fulfill(true)
            fulfill(false)
        }
        
        testExpectation { fulfillExpectation in
            promise.then { value in
                XCTAssert(value)
                fulfillExpectation()
            }
        }
    }
    
    func testRejectThenResolve() {
        let promise = FailablePromise<Void> { fulfill, reject in
            reject(SimpleError())
            fulfill(())
        }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }

    func testDoubleReject() {
        let promise = FailablePromise<Void> { _, reject in
            reject(SimpleError())
            reject(SimpleError())
        }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }

    func testResolveThenReject() {
        let promise = FailablePromise<Void> { fulfill, reject in
            fulfill(())
            reject(SimpleError())
        }
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
            
            promise.catch { _ in
                XCTFail()
            }
        }
    }
}
