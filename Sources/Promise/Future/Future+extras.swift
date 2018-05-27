public extension Future {
    convenience init(_ block: () throws -> Value) {
        self.init { promise in
            promise.resolve(block)
        }
    }
    
    static func fulfilled(with value: Value) -> Future {
        return Future { promise in
            promise.fulfill(with: value)
        }
    }
    
    static func rejected(with error: Error) -> Future {
        return Future { promise in
            promise.reject(with: error)
        }
    }
    
    func transform<T>(_ transform: @escaping (Promise<T>, Value) throws -> Void) -> Future<T> {
        return .init { promise in
            then { value in
                promise.do { try transform(promise, value) }
            }
            
            `catch`(promise.reject)
        }
    }
    
    func map<T>(_ transform: @escaping (Value) throws -> T) -> Future<T> {
        return self.transform { promise, value in
            promise.fulfill(with: try transform(value))
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> Future<T>) -> Future<T> {
        return self.transform { promise, value in
            promise.observe(try transform(value))
        }
    }
    
    func transformError(_ transform: @escaping (Promise<Value>, Error) throws -> Void) -> Future {
        return .init { promise in
            then(promise.fulfill)
            
            `catch` { error in
                promise.do { try transform(promise, error) }
            }
        }
    }
    
    func mapError(_ transform: @escaping (Error) throws -> Error) -> Future {
        return self.transformError { _, error in
            throw try transform(error)
        }
    }
    
    func recover(_ recovery: @escaping (Error) throws -> Future) -> Future {
        return transformError { promise, error in
            promise.observe(try recovery(error))
        }
    }
    
    func `guard`(_ block: @escaping (Value) throws -> Void) -> Future {
        return map { value in
            try block(value)
            return value
        }
    }
    
    @discardableResult
    func with(_ block: @escaping (Future) -> Void) -> Future {
        block(self)
        return self
    }
}

public func race<T>(_ left: Future<T>, _ right: Future<T>) -> Future<T> {
    return Future { promise in
        promise.observe(left)
        promise.observe(right)
    }
}

public func zip<A, B>(_ left: Future<A>, _ right: Future<B>) -> Future<(A, B)> {
    return left.flatMap { x in
        right.map { y in (x, y) }
    }
}

public extension Future where Value == Void {
    static var fulfilled: Future {
        return .fulfilled(with: ())
    }
}

private func _race<T>(_ left: Future<T>, _ right: Future<T>) -> Future<T> {
    return race(left, right)
}

public extension Sequence {
    /// Wait for all the promises you give it to fulfill, and once they have, fulfill itself
    /// with the array of all fulfilled values. Preserves the order of the promises.
    func traverse<T>() -> Future<[T]> where Element == Future<T> {
        return reduce(.fulfilled(with: [])) {
            zip($0, $1).map { $0 + [$1] }
        }
    }
    
    /// Fulfills or rejects with the first promise that completes
    /// (as opposed to waiting for all of them, like `.all` does).
    func race<T>() -> Future<T> where Element == Future<T> {
        return reduce(.pending, _race)
    }
}
