public final class Future<Value> {
    private let result: BasicFuture<Result<Value>>
    
    init(result: BasicFuture<Result<Value>>) {
        self.result = result
    }
}

private extension Future {
    convenience init(context: ExecutionContext?, _ block: (Promise<Value>) throws -> Void) {
        let result = BasicPromise<Result<Value>>()
        self.init(result: context.map(result.future.changeContext) ?? result.future)
        
        let promise = Promise(future: self, result: result)
        promise.do { try block(promise) }
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
        self.init(context: nil, block)
    }
    
    @discardableResult
    func then(_ handler: @escaping (Value) -> Void) -> Future {
        result.then { result in
            if case .success(let value) = result {
                handler(value)
            }
        }
        
        return self
    }
    
    @discardableResult
    func `catch`(_ handler: @escaping (Error) -> Void) -> Future {
        result.then { result in
            if case .failure(let error) = result {
                handler(error)
            }
        }
        
        return self
    }
    
    @discardableResult
    func always(_ handler: @escaping () -> Void) -> Future {
        result.then { _ in
            handler()
        }
        
        return self
    }
    
    func changeContext(_ context: @escaping ExecutionContext) -> Future {
        return Future(context: context) { promise in
            promise.observe(self)
        }
    }
}
