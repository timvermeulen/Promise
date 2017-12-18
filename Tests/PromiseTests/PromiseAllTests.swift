import XCTest
import Promise

final class PromiseAllTests: XCTestCase {
    func testAll() {
        let promise1 = FailablePromise.fulfilled(with: 1)
        let promise2 = FailablePromise.fulfilled(with: 2).delayed(by: 0.1)
        let promise3 = FailablePromise.fulfilled(with: 3).delayed(by: 0.3)
        let promise4 = FailablePromise.fulfilled(with: 4).delayed(by: 0.2)
        
        let final = [promise1, promise2, promise3, promise4].all()
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssertEqual(value, [1, 2, 3, 4])
                fulfillExpectation()
            }
        }
    }
    
    func testAllWithPreFulfilledValues() {
        let promise1 = FailablePromise.fulfilled(with: 1)
        let promise2 = FailablePromise.fulfilled(with: 2)
        let promise3 = FailablePromise.fulfilled(with: 3)
        
        let final = [promise1, promise2, promise3].all()
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssertEqual(value, [1, 2, 3])
                fulfillExpectation()
            }
        }
    }
    
    func testAllWithEmptyArray() {
        let promises: [FailablePromise<Void>] = []
        let final = promises.all()
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssert(value.isEmpty)
                fulfillExpectation()
            }
        }
    }
    
    func testAllWithRejectionHappeningFirst() {
        let promise1 = FailablePromise.fulfilled
        let promise2 = FailablePromise<Void>.rejected(with: SimpleError()).delayed(by: 0.5)
        
        let final = [promise1, promise2].all()
        
        testExpectation(description: "`Promise.all` should wait until multiple promises are fulfilled before returning.") { fulfillExpectation in
            final.then { _ in
                XCTFail()
            }
            
            final.catch { _ in
                fulfillExpectation()
            }
            
            final.then { _ in
                XCTFail()
            }
        }
    }
    
    func testAllWithRejectionHappeningLast() {
        let promise1 = FailablePromise.fulfilled
        let promise2 = FailablePromise<Void>.rejected(with: SimpleError()).delayed(by: 0.5)
        
        let final = [promise1, promise2].all()
        
        testExpectation(description: "`Promise.all` should wait until multiple promises are fulfilled before returning.") { fulfillExpectation in
            final.then { _ in
                XCTFail()
            }
            
            final.catch { _ in
                fulfillExpectation()
            }
            
            final.then { _ in
                XCTFail()
            }
        }
    }
}
