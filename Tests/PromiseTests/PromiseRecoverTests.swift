import XCTest
import Promise

final class PromiseRecoverTests: XCTestCase {
    func testRecover() {
        let promise = FailablePromise<Void>.rejected(with: SimpleError()).delayed(by: 0.1, on: .main)
        
        let recovered = promise.recover { _ in
            return FailablePromise {}
        }
        
        testExpectation { fulfillExpectation in
            recovered.then {
                fulfillExpectation()
            }
        }
    }
    
    func testRecoverWithThrowingFunction() {
        let promise = FailablePromise<Void>.rejected(with: SimpleError()).delayed(by: 0.1, on: .main)
        
        let recovered = promise.recover { _ in
            _ = try JSONSerialization.data(withJSONObject: ["key": "value"])
            return .fulfilled
        }
        
        testExpectation { fulfillExpectation in
            recovered.then {
                fulfillExpectation()
            }
        }
    }
    
    func testRecoverWithThrowingFunctionError() {
        let promise = FailablePromise<Void>.rejected(with: SimpleError()).delayed(by: 0.1, on: .main)
        
        let recovered = promise.recover { error -> FailablePromise<Void> in
            throw SimpleError()
        }
        
        testExpectation { fulfillExpectation in
            recovered.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testRecoverInstant() {
        let promise = FailablePromise<Void>.rejected(with: SimpleError())
        
        let recovered = promise.recover { _ in
            return .fulfilled
        }
        
        testExpectation { fulfillExpectation in
            recovered.then {
                fulfillExpectation()
            }
        }
    }
    
    func testIgnoreRecover() {
        let promise = FailablePromise.fulfilled(with: true).delayed(by: 0.1, on: .main)
        
        let recovered = promise.recover { _ in
            return FailablePromise.fulfilled(with: false)
        }
        
        testExpectation { fulfillExpectation in
            recovered.then { value in
                XCTAssert(value)
                fulfillExpectation()
            }
        }
    }
    
    func testIgnoreRecoverInstant() {
        let promise = FailablePromise.fulfilled(with: true)
        
        let recovered = promise.recover { _ in
            return FailablePromise.fulfilled(with: false)
        }
        
        testExpectation { fulfillExpectation in
            recovered.then { value in
                XCTAssert(value)
                fulfillExpectation()
            }
        }
    }
}
