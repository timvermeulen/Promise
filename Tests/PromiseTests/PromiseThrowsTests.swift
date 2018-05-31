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
        
        testExpectation { fulfill in
            future.then { value in
                XCTAssertFalse(value)
                fulfill()
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
        
        testExpectation { fulfill in
            future.catch { _ in
                fulfill()
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
        
        testExpectation { fulfill in
            future.then { value in
                XCTAssertFalse(value)
                fulfill()
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
        
        testExpectation { fulfill in
            future.catch { _ in
                fulfill()
            }
        }
    }
}
