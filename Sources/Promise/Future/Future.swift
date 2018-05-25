public final class Promise<Value> {
    public let future: Future<Value>
    
    fileprivate init(future: Future<Value>) {
        self.future = future
    }
}

public extension Promise {
    convenience init() {
        self.init(future: .pending)
    }
    
    func fulfill(with value: Value) {
        future.value.fulfill(with: value)
    }
    
    func reject(with error: Error) {
        future.error.fulfill(with: error)
    }
}

extension Promise where Value == Void {
    public func fulfill() {
        fulfill(with: ())
    }
}

public final class Future<Value> {
    fileprivate let value: BasicPromise<Value>
    fileprivate let error: BasicPromise<Error>
    
    private let result: BasicFuture<Result<Value>>
    
    private init(value: BasicPromise<Value>, error: BasicPromise<Error>) {
        self.value = value
        self.error = error
        
        result = race(
            value.future.map(Result.success),
            error.future.map(Result.failure)
        )
    }
    
    private convenience init() {
        self.init(value: BasicPromise(), error: BasicPromise())
    }
}

public extension Future {
    static var pending: Future {
        return Future()
    }
    
    convenience init(_ block: (Promise<Value>) throws -> Void) {
        self.init()
        let promise = Promise(future: self)
        
        do {
            try block(promise)
        } catch {
            promise.reject(with: error)
        }
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
