import Foundation

public final class FailablePromise<Value> {
    private let (valuePromise, fulfill) = Promise<Value>.make()
    private let (errorPromise, reject) = Promise<Error>.make()
    private let resultPromise: Promise<Result<Value>>
    
    init() {
        resultPromise = valuePromise.map(Result.success).racing(with: errorPromise.map(Result.failure))
    }
}

public extension FailablePromise {
    convenience init(_ work: (_ fulfill: @escaping (Value) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
        self.init()
        
        do {
            try work(fulfill, reject)
        } catch {
            reject(error)
        }
    }
    
    static func makePromise() -> (promise: FailablePromise, fulfill: (Value) -> Void, reject: (Error) -> Void) {
        let promise = FailablePromise()
        return (promise, promise.fulfill, promise.reject)
    }
    
    func then(_ handler: @escaping (Value) -> Void) {
        resultPromise.then { result in
            if case .success(let value) = result {
                handler(value)
            }
        }
    }
    
    func `catch`(_ handler: @escaping (Error) -> Void) {
        resultPromise.then { result in
            if case .failure(let error) = result {
                handler(error)
            }
        }
    }
    
    func always(_ handler: @escaping () -> Void) {
        resultPromise.then { _ in
            handler()
        }
    }
}
