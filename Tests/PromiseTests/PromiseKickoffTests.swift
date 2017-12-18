import XCTest
import Promise

final class PromiseKickoffTests: XCTestCase {
    func testKickoff() {
        let promise = FailablePromise.kickoff {}
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testFailingKickoff() {
        let promise = FailablePromise.kickoff {
            throw SimpleError()
        }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
