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
        
        assertIsFulfilled(future, with: false)
    }
    
    func testThrowsInMappingWithError() {
        let future = Future.fulfilled(with: true).map { value -> Bool in
            if value {
                throw SimpleError()
            } else {
                return false
            }
        }
        
        assertIsRejected(future)
    }
    
    func testThrowsInFlatmapping() {
        let future = Future.fulfilled(with: true).flatMap { value -> Future<Bool> in
            if !value {
                throw SimpleError()
            } else {
                return Future.fulfilled(with: false)
            }
        }
        
        assertIsFulfilled(future, with: false)
    }
    
    func testThrowsInFlatmappingWithError() {
        let future = Future.fulfilled(with: true).flatMap { value -> Future<Bool> in
            if value {
                throw SimpleError()
            } else {
                return Future.fulfilled(with: false)
            }
        }
        
        assertIsRejected(future)
    }
}
