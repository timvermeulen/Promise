import XCTest
import Promise

final class PromiseGuardTests: XCTestCase {
    func testGuardRejects() {
        let promise = FailablePromise.fulfilled(with: true).guard {
            if $0 { throw SimpleError() }
        }
        
        promise.assertIsRejected()
    }
    
    func testGuardSucceeds() {
        let promise = FailablePromise.fulfilled.guard {}
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testGuardOnlyCalledOnSucceess() {
        let promise = FailablePromise.rejected(with: SimpleError()).guard { XCTFail() }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
