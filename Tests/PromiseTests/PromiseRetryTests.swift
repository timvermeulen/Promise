import XCTest
import Promise

final class PromiseRetryTests: XCTestCase {
    func testRetry() {
        var currentCount = 3
        
        let promise = FailablePromise<Void>.retry(count: 3, delay: 0) {
            if currentCount == 1 {
                return .fulfilled
            } else {
                currentCount -= 1
                return FailablePromise.rejected(with: SimpleError())
            }
        }
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testRetryWithInstantSuccess() {
        var flag = true
        
        let promise = FailablePromise<Void>.retry(count: 3, delay: 0) {
            if !flag {
                XCTFail()
            }
            
            flag = false
            return .fulfilled
        }
        
        testExpectation { fulfillExpectation in
            promise.then {
                fulfillExpectation()
            }
        }
    }
    
    func testRetryWithNeverSuccess() {
        let promise = FailablePromise<Void>.retry(count: 3, delay: 0) {
            FailablePromise.rejected(with: SimpleError())
        }
        
        testExpectation { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
