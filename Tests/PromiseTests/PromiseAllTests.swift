import XCTest
import Promise

final class PromiseAllTests: XCTestCase {
    func testAll() {
        let future1 = Future.fulfilled(with: 1)
        let future2 = Future.fulfilled(with: 2).delayed(by: 0.1)
        let future3 = Future.fulfilled(with: 3).delayed(by: 0.3)
        let future4 = Future.fulfilled(with: 4).delayed(by: 0.2)
        
        let all = [future1, future2, future3, future4].all()
        assertWillBeFulfilled(all, with: [1, 2, 3, 4])
    }
    
    func testAllWithPreFulfilledValues() {
        let future1 = Future.fulfilled(with: 1)
        let future2 = Future.fulfilled(with: 2)
        let future3 = Future.fulfilled(with: 3)
        
        let all = [future1, future2, future3].all()
        assertIsFulfilled(all, with: [1, 2, 3])
    }
    
    func testAllWithEmptyArray() {
        let futures: [Future<Void>] = []
        let all = futures.all()
        
        testCurrentValue(of: all) { value in
            XCTAssert(value.isEmpty)
        }
    }
    
    func testAllWithRejectionHappeningFirst() {
        let future1 = Future.fulfilled
        let future2 = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.5)
        
        let all = [future1, future2].all()
        assertWillBeRejected(all)
    }
    
    func testAllWithRejectionHappeningLast() {
        let future1 = Future.fulfilled
        let future2 = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.5)
        
        let all = [future1, future2].all()
        assertWillBeRejected(all)
    }
}
