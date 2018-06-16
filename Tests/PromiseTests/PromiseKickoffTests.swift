import XCTest
import Promise

final class PromiseKickoffTests: XCTestCase {
    func testKickoff() {
        let future = Future {}
        assertIsFulfilled(future)
    }
    
    func testFailingKickoff() {
        let future = Future { throw SimpleError() }
        assertIsRejected(future)
    }
}
