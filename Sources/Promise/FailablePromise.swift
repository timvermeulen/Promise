import Foundation

public final class FailablePromise<Value> {
    private let valuePromise: Promise<Value>
    private let errorPromise: Promise<Swift.Error>
    private let resultPromise: Promise<Result<Value>>
    
    private let fulfill: (Value) -> Void
    private let reject: (Swift.Error) -> Void
    
    private init() {
        (valuePromise, fulfill) = Promise<Value>.makePromise()
        (errorPromise, reject) = Promise<Swift.Error>.makePromise()
        resultPromise = valuePromise.map(Result.success).race(with: errorPromise.map(Result.failure))
    }
}

public extension FailablePromise {
    convenience init(_ work: @escaping (_ fulfill: @escaping (Value) -> Void, _ reject: @escaping (Swift.Error) -> Void) throws -> Void) {
        self.init()
        
        do {
            try work(fulfill, reject)
        } catch {
            reject(error)
        }
    }
    
    static var pending: FailablePromise {
        return FailablePromise()
    }
    
    static func makePromise() -> (promise: FailablePromise, fulfill: (Value) -> Void, reject: (Swift.Error) -> Void) {
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
    
    func `catch`(_ handler: @escaping (Swift.Error) -> Void) {
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
