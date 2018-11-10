import XCTest
import Promise

final class PromiseRecoverTests: XCTestCase {
    func testRecover() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.1)
        let recovered = future.mapError { _ in }
        assertWillBeFulfilled(recovered)
    }
    
    func testRecoverInstant() {
        let future = Future<Void>.rejected(with: SimpleError())
        let recovered = future.mapError { _ in }
        assertWillBeFulfilled(recovered)
    }
    
    func testRecoverWithThrowingFunctionError() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.1)
        let recovered: Future<Void> = future.mapError { error in throw SimpleError() }
        assertWillBeRejected(recovered)
    }
    
    func testIgnoreRecover() {
        let future = Future.fulfilled(with: true).delayed(by: 0.1)
        let recovered = future.mapError { _ in false }
        assertWillBeFulfilled(recovered, with: true)
    }
    
    func testIgnoreRecoverInstant() {
        let future = Future.fulfilled(with: true)
        let recovered = future.mapError { _ in false }
        assertWillBeFulfilled(recovered, with: true)
    }
}
