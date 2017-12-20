import XCTest
import Promise

final class PromiseZipTests: XCTestCase {
    func testZip() {
        let promise = FailablePromise.fulfilled.zipped(with: .fulfilled)

        testExpectation() { fulfillExpectation in
            promise.then { _ in
                fulfillExpectation()
            }
        }
    }

    func testAsyncZip() {
        let promise1 = FailablePromise.fulfilled.delayed(by: 1 / 3)
        let promise2 = FailablePromise.fulfilled.delayed(by: 2 / 3)

        let zipped = promise1.zipped(with: promise2)
        
        testExpectation() { fulfillExpectation in
            zipped.then { _ in
                fulfillExpectation()
            }
        }
    }
}
