import XCTest
import Promise

final class PromiseKickoffTests: XCTestCase {
    func testKickoff() {
        let future = Future {}
        
        testExpectation { fulfill in
            future.then {
                fulfill()
            }
        }
    }
    
    func testFailingKickoff() {
        let future = Future {
            throw SimpleError()
        }
        
        testExpectation { fulfill in
            future.catch { _ in
                fulfill()
            }
        }
    }
}
