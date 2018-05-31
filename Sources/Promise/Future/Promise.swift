public final class Promise<Value> {
    public let future: Future<Value>
    private let resolver: Resolver<Value>
    
    init(future: Future<Value>, result: BasicPromise<Result<Value>>) {
        self.future = future
        self.resolver = Resolver(result: result)
    }
}

public extension Promise {
    convenience init() {
        let result = BasicPromise<Result<Value>>()
        let future = Future<Value>(result: result.future)
        
        self.init(future: future, result: result)
    }
    
    func fulfill(with value: Value) {
        resolver.fulfill(with: value)
    }
    
    func reject(with error: Error) {
        resolver.reject(with: error)
    }
    
    func `do`(_ block: () throws -> Void) {
        resolver.do(block)
    }
    
    func resolve(_ block: () throws -> Value) {
        resolver.resolve(block)
    }
    
    func observe(_ future: Future<Value>) {
        resolver.observe(future)
    }
}

extension Promise where Value == Void {
    public func fulfill() {
        resolver.fulfill()
    }
}
