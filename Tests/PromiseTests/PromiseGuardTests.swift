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
        
        testExpectation { fulfillExpectation in
            future.then {
                fulfillExpectation()
            }
        }
    }
    
    func testGuardOnlyCalledOnSucceess() {
        let future = Future.rejected(with: SimpleError()).guard { XCTFail() }
        
        testExpectation { fulfillExpectation in
            future.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
