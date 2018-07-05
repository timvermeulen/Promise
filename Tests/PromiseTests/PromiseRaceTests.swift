import XCTest
import Promise

final class PromiseRaceTests: XCTestCase {
    func testRace() {
        let future1 = Future.fulfilled(with: 1).delayed(by: 2 / 4)
        let future2 = Future.fulfilled(with: 2).delayed(by: 1 / 4)
        let future3 = Future.fulfilled(with: 3).delayed(by: 3 / 4)
        
        let first = [future1, future2, future3].race()
        assertWillBeFulfilled(first, with: 2)
    }
    
    func testRaceFailure() {
        let future1 = Future<Void>.rejected(with: SimpleError()).delayed(by: 1 / 3)
        let future2 = Future.fulfilled.delayed(by: 2 / 3)
        
        let first = race(future1, future2)
        assertWillBeRejected(first)
    }
    
    func testInstantResolve() {
        let future1 = Future.fulfilled(with: true)
        let future2 = Future.fulfilled(with: false).delayed(by: 0.5)
        
        let first = race(future1, future2)
        assertWillBeFulfilled(first, with: true)
    }
    
    func testInstantReject() {
        let future1 = Future<Void>.rejected(with: SimpleError())
        let future2 = Future.fulfilled.delayed(by: 0.5)
        
        let first = race(future1, future2)
        assertIsRejected(first)
    }
}
