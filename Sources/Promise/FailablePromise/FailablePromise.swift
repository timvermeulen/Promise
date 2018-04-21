public final class FailablePromise<Value> {
    private let fulfill: (Value) -> Void
    private let reject: (Error) -> Void
    private let result: Promise<Result<Value>>
    
    init() {
        let (valuePromise, fulfill) = Promise<Value>.make()
        let (errorPromise, reject) = Promise<Error>.make()
        
        self.fulfill = fulfill
        self.reject = reject
        
        self.result = race(
            valuePromise.map(Result.success),
            errorPromise.map(Result.failure)
        )
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
    
    static func make() -> (promise: FailablePromise, fulfill: (Value) -> Void, reject: (Error) -> Void) {
        let promise = FailablePromise()
        return (promise, promise.fulfill, promise.reject)
    }
    
    func then(_ handler: @escaping (Value) -> Void) {
        result.then { result in
            if case .success(let value) = result {
                handler(value)
            }
        }
    }
    
    func `catch`(_ handler: @escaping (Error) -> Void) {
        result.then { result in
            if case .failure(let error) = result {
                handler(error)
            }
        }
    }
    
    func always(_ handler: @escaping () -> Void) {
        result.then { _ in
            handler()
        }
    }
}
