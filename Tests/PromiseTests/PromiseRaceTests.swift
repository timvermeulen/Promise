import XCTest
import Promise

final class PromiseRaceTests: XCTestCase {
    func testRace() {
        let promise1 = FailablePromise.fulfilled(with: 1).delayed(by: 0.1)
        let promise2 = FailablePromise.fulfilled(with: 2).delayed(by: 0.05)
        let promise3 = FailablePromise.fulfilled(with: 3).delayed(by: 0.15)
        
        let final = [promise1, promise2, promise3].race()
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssertEqual(value, 2)
                fulfillExpectation()
            }
        }
    }
    
    func testRaceFailure() {
        let promise1 = FailablePromise<Void>.rejected(with: SimpleError()).delayed(by: 0.05)
        let promise2 = FailablePromise.delay(0.1).map {}
        let final = [promise1, promise2].race()
        
        testExpectation { fulfillExpectation in
            final.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testInstantResolve() {
        let promise1 = FailablePromise.fulfilled(with: true)
        let promise2 = FailablePromise.delay(0.1).map { false }
        
        let final = [promise1, promise2].race()
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssert(value)
                fulfillExpectation()
            }
        }
    }
    
    func testInstantReject() {
        let promise1 = FailablePromise<Void>.rejected(with: SimpleError())
        let promise2 = FailablePromise.delay(0.1).map { () }
        
        let final = [promise1, promise2].race()
        
        testExpectation { fulfillExpectation in
            final.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
