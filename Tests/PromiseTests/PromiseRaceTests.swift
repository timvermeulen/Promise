import XCTest
import Promise

final class PromiseRaceTests: XCTestCase {
    func testRace() {
        let future1 = Future.fulfilled(with: 1).delayed(by: 2 / 4)
        let future2 = Future.fulfilled(with: 2).delayed(by: 1 / 4)
        let future3 = Future.fulfilled(with: 3).delayed(by: 3 / 4)
        
        let final = [future1, future2, future3].race()
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssertEqual(value, 2)
                fulfillExpectation()
            }
        }
    }
    
    func testRaceFailure() {
        let future1 = Future<Void>.rejected(with: SimpleError()).delayed(by: 1 / 3)
        let future2 = Future.fulfilled.delayed(by: 2 / 3)
        
        let final = race(future1, future2)
        
        testExpectation { fulfillExpectation in
            final.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testInstantResolve() {
        let future1 = Future.fulfilled(with: true)
        let future2 = Future.fulfilled(with: false).delayed(by: 0.5)
        
        let final = race(future1, future2)
        
        testExpectation { fulfillExpectation in
            final.then { value in
                XCTAssert(value)
                fulfillExpectation()
            }
        }
    }
    
    func testInstantReject() {
        let future1 = Future<Void>.rejected(with: SimpleError())
        let future2 = Future.fulfilled.delayed(by: 0.5)
        
        let final = race(future1, future2)
        
        testExpectation { fulfillExpectation in
            final.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
