import XCTest
import Promise

final class PromiseZipTests: XCTestCase {
    func testZip() {
        let promise = zip(FailablePromise.fulfilled, .fulfilled)

        testExpectation() { fulfillExpectation in
            promise.then { _ in
                fulfillExpectation()
            }
        }
    }

    func testAsyncZip() {
        let promise1 = FailablePromise.fulfilled.delayed(by: 1 / 3)
        let promise2 = FailablePromise.fulfilled.delayed(by: 2 / 3)

        let zipped = zip(promise1, promise2)
        
        testExpectation() { fulfillExpectation in
            zipped.then { _ in
                fulfillExpectation()
            }
        }
    }
}
