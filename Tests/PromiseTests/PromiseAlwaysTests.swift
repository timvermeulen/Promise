import XCTest
import Promise

final class PromiseAlwaysTests: XCTestCase {
    func testAlways() {
        let future = Future.fulfilled.delayed(by: 0.5, on: .main)
        
        testExpectation { fulfillExpectation in
            future.always {
                fulfillExpectation()
            }
        }
    }
    
    func testAlwaysRejects() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.5, on: .main)
        
        testExpectation { fulfillExpectation in
            future.always {
                fulfillExpectation()
            }
        }
    }
    
    func testAlwaysInstantFulfill() {
        let future = Future.fulfilled
        
        testExpectation { fulfillExpectation in
            future.always {
                fulfillExpectation()
            }
        }
    }
    
    func testAlwaysInstantReject() {
        let future = Future<Void>.rejected(with: SimpleError())
        
        testExpectation { fulfillExpectation in
            future.always {
                fulfillExpectation()
            }
        }
    }
}
