import XCTest
import Promise

final class PromiseKickoffTests: XCTestCase {
    func testKickoff() {
        let promise = FailablePromise {}
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testFailingKickoff() {
        let promise = FailablePromise {
            throw SimpleError()
        }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
