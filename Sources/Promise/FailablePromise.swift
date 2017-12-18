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
    convenience init(on context: ExecutionContext = .defaultForeground, work: @escaping (_ fulfill: @escaping (Value) -> Void, _ reject: @escaping (Swift.Error) -> Void) throws -> Void) {
        self.init()
        
        context.execute {
            do {
                try work(self.fulfill, self.reject)
            } catch {
                self.reject(error)
            }
        }
    }
    
    static var pending: FailablePromise {
        return FailablePromise()
    }
    
    static func makePromise() -> (promise: FailablePromise, fulfill: (Value) -> Void, reject: (Swift.Error) -> Void) {
        let promise = FailablePromise()
        return (promise, promise.fulfill, promise.reject)
    }
    
    func then(on context: ExecutionContext = .defaultForeground, _ handler: @escaping (Value) -> Void) {
        resultPromise.then(on: context) { result in
            if case .success(let value) = result {
                handler(value)
            }
        }
    }
    
    func `catch`(on context: ExecutionContext = .defaultForeground, _ handler: @escaping (Swift.Error) -> Void) {
        resultPromise.then(on: context) { result in
            if case .failure(let error) = result {
                handler(error)
            }
        }
    }
    
    func always(on context: ExecutionContext = .defaultForeground, _ handler: @escaping () -> Void) {
        resultPromise.then(on: context) { _ in
            handler()
        }
    }
}
