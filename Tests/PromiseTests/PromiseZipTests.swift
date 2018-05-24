import XCTest
import Promise

final class PromiseZipTests: XCTestCase {
    func testZip() {
        let future = zip(Future.fulfilled, .fulfilled)

        testExpectation() { fulfillExpectation in
            future.then { _ in
                fulfillExpectation()
            }
        }
    }

    func testAsyncZip() {
        let future1 = Future.fulfilled.delayed(by: 1 / 3, on: .main)
        let future2 = Future.fulfilled.delayed(by: 2 / 3, on: .main)

        let zipped = zip(future1, future2)
        
        testExpectation() { fulfillExpectation in
            zipped.then { _ in
                fulfillExpectation()
            }
        }
    }
}
