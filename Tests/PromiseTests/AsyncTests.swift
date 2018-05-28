import XCTest
import Promise

final class AsyncTests: XCTestCase {
    func testOn() {
        testExpectation { fulfill in
            DispatchQueue.global().async {
                let future = Future.fulfilled.on(.main)
                XCTAssertFalse(Thread.isMainThread)
                
                future.then {
                    XCTAssert(Thread.isMainThread)
                    fulfill()
                }
            }
        }
    }
}
