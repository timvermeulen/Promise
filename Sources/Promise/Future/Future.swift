public final class Future<Value> {
    private let result: BasicFuture<Result<Value>>
    
    init(result: BasicFuture<Result<Value>>) {
        self.result = result
    }
}

private extension Future {
    convenience init(
        context: @escaping ExecutionContext,
        _ block: (Resolver<Value>) throws -> Void
    ) {
        let result = BasicPromise<Result<Value>>()
        self.init(result: result.future.changeContext(context))
        
        let resolver = Resolver(result: result)
        resolver.do { try block(resolver) }
    }
}

public extension Future {
    static var pending: Future {
        return Future(result: .pending)
    }
    
    convenience init(_ future: BasicFuture<Value>) {
        self.init(result: future.map(Result.success))
    }
    
    convenience init(_ block: (Resolver<Value>) throws -> Void) {
        let result = BasicPromise<Result<Value>>()
        self.init(result: result.future)
        
        let resolver = Resolver(result: result)
        resolver.do { try block(resolver) }
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
        return Future(context: context) { resolver in
            resolver.observe(self)
        }
    }
}
