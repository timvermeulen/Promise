import XCTest
import Promise

final class PromiseThrowsTests: XCTestCase {
    func testThrowsInMapping() {
        let future = Future.fulfilled(with: true).map { value -> Bool in
            if !value {
                throw SimpleError()
            } else {
                return false
            }
        }
        
        testExpectation() { fulfillExpectation in
            future.then { value in
                XCTAssertFalse(value)
                fulfillExpectation()
            }
        }
    }
    
    func testThrowsInMappingWithError() {
        let future = Future.fulfilled(with: true).map { value -> Bool in
            if value {
                throw SimpleError()
            } else {
                return false
            }
        }
        
        testExpectation() { fulfillExpectation in
            future.catch { _ in
                fulfillExpectation()
            }
        }
    }
    
    func testThrowsInFlatmapping() {
        let future = Future.fulfilled(with: true).flatMap { value -> Future<Bool> in
            if !value {
                throw SimpleError()
            } else {
                return Future.fulfilled(with: false)
            }
        }
        
        testExpectation() { fulfillExpectation in
            future.then { value in
                XCTAssertFalse(value)
                fulfillExpectation()
            }
        }
    }
    
    func testThrowsInFlatmappingWithError() {
        let future = Future.fulfilled(with: true).flatMap { value -> Future<Bool> in
            if value {
                throw SimpleError()
            } else {
                return Future.fulfilled(with: false)
            }
        }
        
        testExpectation() { fulfillExpectation in
            future.catch { _ in
                fulfillExpectation()
            }
        }
    }
}
