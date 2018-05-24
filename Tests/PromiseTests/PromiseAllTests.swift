import XCTest
import Promise

final class PromiseAllTests: XCTestCase {
    func testAll() {
        let future1 = Future.fulfilled(with: 1)
        let future2 = Future.fulfilled(with: 2).delayed(by: 0.1, on: .main)
        let future3 = Future.fulfilled(with: 3).delayed(by: 0.3, on: .main)
        let future4 = Future.fulfilled(with: 4).delayed(by: 0.2, on: .main)
        
        let final = [future1, future2, future3, future4].all()
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssertEqual(value, [1, 2, 3, 4])
                fulfillExpectation()
            }
        }
    }
    
    func testAllWithPreFulfilledValues() {
        let future1 = Future.fulfilled(with: 1)
        let future2 = Future.fulfilled(with: 2)
        let future3 = Future.fulfilled(with: 3)
        
        let final = [future1, future2, future3].all()
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssertEqual(value, [1, 2, 3])
                fulfillExpectation()
            }
        }
    }
    
    func testAllWithEmptyArray() {
        let promises: [Future<Void>] = []
        let final = promises.all()
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssert(value.isEmpty)
                fulfillExpectation()
            }
        }
    }
    
    func testAllWithRejectionHappeningFirst() {
        let future1 = Future.fulfilled
        let future2 = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.5, on: .main)
        
        let final = [future1, future2].all()
        
        testExpectation(description: "`Promise.all` should wait until multiple promises are fulfilled before returning.") { fulfillExpectation in
            final.then { _ in
                XCTFail()
            }
            
            final.catch { _ in
                fulfillExpectation()
            }
            
            final.then { _ in
                XCTFail()
            }
        }
    }
    
    func testAllWithRejectionHappeningLast() {
        let future1 = Future.fulfilled
        let future2 = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.5, on: .main)
        
        let final = [future1, future2].all()
        
        testExpectation(description: "`Promise.all` should wait until multiple promises are fulfilled before returning.") { fulfillExpectation in
            final.then { _ in
                XCTFail()
            }
            
            final.catch { _ in
                fulfillExpectation()
            }
            
            final.then { _ in
                XCTFail()
            }
        }
    }
}
