public final class Promise<Value> {
    public let future: Future<Value>
    private let result: BasicPromise<Result<Value>>
    
    fileprivate init(future: Future<Value>, result: BasicPromise<Result<Value>>) {
        self.future = future
        self.result = result
    }
}

public extension Promise {
    convenience init() {
        let result = BasicPromise<Result<Value>>()
        let future = Future<Value>(result: result.future)
        
        self.init(future: future, result: result)
    }
    
    func fulfill(with value: Value) {
        result.fulfill(with: .success(value))
    }
    
    func reject(with error: Error) {
        result.fulfill(with: .failure(error))
    }
    
    func `do`(_ block: () throws -> Void) {
        do {
            try block()
        } catch {
            reject(with: error)
        }
    }
    
    func resolve(_ block: () throws -> Value) {
        `do` { fulfill(with: try block()) }
    }
    
    func observe(_ future: Future<Value>) {
        future.then(fulfill)
        future.catch(reject)
    }
}

extension Promise where Value == Void {
    public func fulfill() {
        fulfill(with: ())
    }
}

public final class Future<Value> {
    private let result: BasicFuture<Result<Value>>
    
    fileprivate init(result: BasicFuture<Result<Value>>) {
        self.result = result
    }
}

public extension Future {
    static var pending: Future {
        return Future(result: .pending)
    }
    
    convenience init(_ future: BasicFuture<Value>) {
        self.init(result: future.map(Result.success))
    }
    
    convenience init(_ block: (Promise<Value>) throws -> Void) {
        let result = BasicPromise<Result<Value>>()
        self.init(result: result.future)
        let promise = Promise(future: self, result: result)
        
        promise.do { try block(promise) }
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
