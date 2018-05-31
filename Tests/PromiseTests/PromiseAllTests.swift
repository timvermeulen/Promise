import XCTest
import Promise

final class PromiseAllTests: XCTestCase {
    func testAll() {
        let future1 = Future.fulfilled(with: 1)
        let future2 = Future.fulfilled(with: 2).delayed(by: 0.1)
        let future3 = Future.fulfilled(with: 3).delayed(by: 0.3)
        let future4 = Future.fulfilled(with: 4).delayed(by: 0.2)
        
        let final = [future1, future2, future3, future4].traverse()
        
        testExpectation { fulfill in
            final.then { value in
                XCTAssertEqual(value, [1, 2, 3, 4])
                fulfill()
            }
        }
    }
    
    func testAllWithPreFulfilledValues() {
        let future1 = Future.fulfilled(with: 1)
        let future2 = Future.fulfilled(with: 2)
        let future3 = Future.fulfilled(with: 3)
        
        let final = [future1, future2, future3].traverse()
        
        testExpectation { fulfill in
            final.then { value in
                XCTAssertEqual(value, [1, 2, 3])
                fulfill()
            }
        }
    }
    
    func testAllWithEmptyArray() {
        let futures: [Future<Void>] = []
        let final = futures.traverse()
        
        testExpectation { fulfill in
            final.then { value in
                XCTAssert(value.isEmpty)
                fulfill()
            }
        }
    }
    
    func testAllWithRejectionHappeningFirst() {
        let future1 = Future.fulfilled
        let future2 = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.5)
        
        let final = [future1, future2].traverse()
        
        testExpectation { fulfill in
            final.then { _ in
                XCTFail()
            }
            
            final.catch { _ in
                fulfill()
            }
            
            final.then { _ in
                XCTFail()
            }
        }
    }
    
    func testAllWithRejectionHappeningLast() {
        let future1 = Future.fulfilled
        let future2 = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.5)
        
        let final = [future1, future2].traverse()
        
        testExpectation { fulfill in
            final.then { _ in
                XCTFail()
            }
            
            final.catch { _ in
                fulfill()
            }
            
            final.then { _ in
                XCTFail()
            }
        }
    }
}
