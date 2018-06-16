import XCTest
import Promise

final class PromiseRecoverTests: XCTestCase {
    func testRecover() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.1)
        let recovered = future.recover { _ in .fulfilled }
        assertWillBeFulfilled(recovered)
    }
    
    func testRecoverInstant() {
        let future = Future<Void>.rejected(with: SimpleError())
        let recovered = future.recover { _ in .fulfilled }
        assertIsFulfilled(recovered)
    }
    
    func testRecoverWithThrowingFunctionError() {
        let future = Future<Void>.rejected(with: SimpleError()).delayed(by: 0.1)
        let recovered: Future<Void> = future.recover { error in throw SimpleError() }
        assertWillBeRejected(recovered)
    }
    
    func testIgnoreRecover() {
        let future = Future.fulfilled(with: true).delayed(by: 0.1)
        let recovered = future.recover { _ in .fulfilled(with: false) }
        assertWillBeFulfilled(recovered, with: true)
    }
    
    func testIgnoreRecoverInstant() {
        let future = Future.fulfilled(with: true)
        let recovered = future.recover { _ in .fulfilled(with: false) }
        assertIsFulfilled(recovered, with: true)
    }
}
