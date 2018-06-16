import XCTest
import Promise

final class PromiseGuardTests: XCTestCase {
    func testGuardRejects() {
        let future = Future.fulfilled(with: true).guard {
            if $0 { throw SimpleError() }
        }
        
        assertIsRejected(future)
    }
    
    func testGuardSucceeds() {
        let future = Future.fulfilled.guard {}
        assertIsFulfilled(future)
    }
    
    func testGuardOnlyCalledOnSuccess() {
        let future = Future.rejected(with: SimpleError()).guard { XCTFail() }
        assertIsRejected(future)
    }
}
