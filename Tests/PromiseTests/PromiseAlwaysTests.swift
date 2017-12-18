import XCTest
import Promise

final class PromiseAlwaysTests: XCTestCase {
    func testAlways() {
        let promise = FailablePromise.fulfilled.delayed(by: 0.5)
        
        testExpectation { fulfillExpectation in
            promise.always {
                fulfillExpectation()
            }
        }
    }
    
    func testAlwaysRejects() {
        let promise = FailablePromise<Void>.rejected(with: SimpleError()).delayed(by: 0.5)
        
        testExpectation { fulfillExpectation in
            promise.always {
                fulfillExpectation()
            }
        }
    }
    
    func testAlwaysInstantFulfill() {
        let promise = FailablePromise.fulfilled
        
        testExpectation { fulfillExpectation in
            promise.always {
                fulfillExpectation()
            }
        }
    }
    
    func testAlwaysInstantReject() {
        let promise = FailablePromise<Void>.rejected(with: SimpleError())
        
        testExpectation { fulfillExpectation in
            promise.always {
                fulfillExpectation()
            }
        }
    }
}
