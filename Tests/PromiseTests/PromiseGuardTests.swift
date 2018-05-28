import XCTest
import Promise

final class PromiseGuardTests: XCTestCase {
    func testGuardRejects() {
        let future = Future.fulfilled(with: true).guard {
            if $0 { throw SimpleError() }
        }
        
        future.assertIsRejected()
    }
    
    func testGuardSucceeds() {
        let future = Future.fulfilled.guard {}
        
        testExpectation { fulfill in
            future.then {
                fulfill()
            }
        }
    }
    
    func testGuardOnlyCalledOnSucceess() {
        let future = Future.rejected(with: SimpleError()).guard { XCTFail() }
        
        testExpectation { fulfill in
            future.catch { _ in
                fulfill()
            }
        }
    }
}
