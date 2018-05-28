public final class Promise<Value> {
    public let future: Future<Value>
    private let result: BasicPromise<Result<Value>>
    
    init(future: Future<Value>, result: BasicPromise<Result<Value>>) {
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
