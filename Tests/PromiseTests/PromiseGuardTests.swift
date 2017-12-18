import XCTest
import Promise

final class PromiseGuardTests: XCTestCase {
    func testGuardRejects() {
        let promise = FailablePromise.fulfilled(with: true).guard { !$0 }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testGuardSucceeds() {
        let promise = FailablePromise.fulfilled.guard { true }
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testGuardOnlyCalledOnSucceess() {
        let promise = FailablePromise.rejected(with: SimpleError()).guard { XCTFail(); return true }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
