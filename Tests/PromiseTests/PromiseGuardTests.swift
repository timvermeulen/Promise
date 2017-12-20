import XCTest
import Promise

final class PromiseGuardTests: XCTestCase {
    func testGuardRejects() {
        let promise = FailablePromise.fulfilled(with: true).guard(orFailWith: SimpleError()) { !$0 }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testGuardSucceeds() {
        let promise = FailablePromise.fulfilled.guard(orFailWith: SimpleError()) { true }
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testGuardOnlyCalledOnSucceess() {
        let promise = FailablePromise.rejected(with: SimpleError()).guard(orFailWith: SimpleError()) { XCTFail(); return true }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
