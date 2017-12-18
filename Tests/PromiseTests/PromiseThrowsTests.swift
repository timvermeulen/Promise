import XCTest
import Promise

final class PromiseThrowsTests: XCTestCase {
    func testThrowsInMapping() {
        let promise = FailablePromise.fulfilled(with: true).map { value -> Bool in
            if !value {
                throw SimpleError()
            } else {
                return false
            }
        }
        
        testExpectation() { fulfillExpectation in
            promise.then { value in
                XCTAssertFalse(value)
                fulfillExpectation()
            }
        }
    }
    
    func testThrowsInMappingWithError() {
        let promise = FailablePromise.fulfilled(with: true).map { value -> Bool in
            if value {
                throw SimpleError()
            } else {
                return false
            }
        }
        
        testExpectation() { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testThrowsInFlatmapping() {
        let promise = FailablePromise.fulfilled(with: true).flatMap { value -> FailablePromise<Bool> in
            if !value {
                throw SimpleError()
            } else {
                return FailablePromise.fulfilled(with: false)
            }
        }
        
        testExpectation() { fulfillExpectation in
            promise.then { value in
                XCTAssertFalse(value)
                fulfillExpectation()
            }
        }
    }
    
    func testThrowsInFlatmappingWithError() {
        let promise = FailablePromise.fulfilled(with: true).flatMap { value -> FailablePromise<Bool> in
            if value {
                throw SimpleError()
            } else {
                return FailablePromise.fulfilled(with: false)
            }
        }
        
        testExpectation() { fulfillExpectation in
            promise.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
