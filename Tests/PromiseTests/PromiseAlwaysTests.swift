import XCTest
import Promise

final class PromiseAlwaysTests: XCTestCase {
    func testAlways() {
        let future = Future.fulfilled.delayed(by: 0.5)
        
        testExpectation { fulfill in
            future.always {
                fulfill()
            }
        }
    }
    
    func testAlwaysRejects() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.5)
        
        testExpectation { fulfill in
            future.always {
                fulfill()
            }
        }
    }
    
    func testAlwaysInstantFulfill() {
        let future = Future.fulfilled
        
        testExpectation { fulfill in
            future.always {
                fulfill()
            }
        }
    }
    
    func testAlwaysInstantReject() {
        let future = Future<Void>.rejected(with: SimpleError())
        
        testExpectation { fulfill in
            future.always {
                fulfill()
            }
        }
    }
}
