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
        let promise1 = FailablePromise.fulfilled.delayed(by: 1 / 3, on: .main)
        let promise2 = FailablePromise.fulfilled.delayed(by: 2 / 3, on: .main)

        let zipped = zip(promise1, promise2)
        
        testExpectation() { fulfillExpectation in
            zipped.then { _ in
                fulfillExpectation()
            }
        }
    }
}
