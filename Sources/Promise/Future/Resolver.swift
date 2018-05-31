public final class Resolver<Value> {
    private let result: BasicPromise<Result<Value>>
    
    init(result: BasicPromise<Result<Value>>) {
        self.result = result
    }
}

public extension Resolver {
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

public extension Resolver where Value == Void {
    func fulfill() {
        fulfill(with: ())
    }
}
