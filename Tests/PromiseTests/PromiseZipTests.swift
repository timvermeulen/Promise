import XCTest
import Promise

final class PromiseZipTests: XCTestCase {
    func testZip() {
        let future = zip(Future.fulfilled, .fulfilled)

        testExpectation() { fulfill in
            future.then { _ in
                fulfill()
            }
        }
    }

    func testAsyncZip() {
        let future1 = Future.fulfilled.delayed(by: 1 / 3)
        let future2 = Future.fulfilled.delayed(by: 2 / 3)

        let zipped = zip(future1, future2)
        
        testExpectation() { fulfill in
            zipped.then { _ in
                fulfill()
            }
        }
    }
}
