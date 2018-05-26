import XCTest
import Promise

final class PromiseRecoverTests: XCTestCase {
    func testRecover() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.1)
        
        let recovered = future.recover { _ in
            return Future {}
        }
        
        testExpectation { fulfillExpectation in
            recovered.then {
                fulfillExpectation()
            }
        }
    }
    
    func testRecoverWithThrowingFunction() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.1)
        
        let recovered = future.recover { _ in
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
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.1)
        
        let recovered = future.recover { error -> Future<Void> in
            throw SimpleError()
        }
        
        testExpectation { fulfillExpectation in
            recovered.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testRecoverInstant() {
        let future = Future<Void>.rejected(with: SimpleError())
        
        let recovered = future.recover { _ in
            return .fulfilled
        }
        
        testExpectation { fulfillExpectation in
            recovered.then {
                fulfillExpectation()
            }
        }
    }
    
    func testIgnoreRecover() {
        let future = Future.fulfilled(with: true).delayed(by: 0.1)
        
        let recovered = future.recover { _ in
            return Future.fulfilled(with: false)
        }
        
        testExpectation { fulfillExpectation in
            recovered.then { value in
                XCTAssert(value)
                fulfillExpectation()
            }
        }
    }
    
    func testIgnoreRecoverInstant() {
        let future = Future.fulfilled(with: true)
        
        let recovered = future.recover { _ in
            return Future.fulfilled(with: false)
        }
        
        testExpectation { fulfillExpectation in
            recovered.then { value in
                XCTAssert(value)
                fulfillExpectation()
            }
        }
    }
}
