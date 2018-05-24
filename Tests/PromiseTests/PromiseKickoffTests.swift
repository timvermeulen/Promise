import XCTest
import Promise

final class PromiseKickoffTests: XCTestCase {
    func testKickoff() {
        let future = Future {}
        
        testExpectation { fulfillExpectation in
            future.then {
                fulfillExpectation()
            }
        }
    }
    
    func testFailingKickoff() {
        let future = Future {
            throw SimpleError()
        }
        
        testExpectation { fulfillExpectation in
            future.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
