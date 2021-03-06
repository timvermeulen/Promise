public final class Promise<Value> {
    private let result: BasicPromise<Result<Value>>
    
    internal init(result: BasicPromise<Result<Value>>) {
        self.result = result
    }
}

public extension Promise {
    func fulfill(with value: Value) {
        result.fulfill(with: .value(value))
    }
    
    func reject(with error: Error) {
        result.fulfill(with: .error(error))
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

public extension Promise where Value == Void {
    func fulfill() {
        fulfill(with: ())
    }
}
