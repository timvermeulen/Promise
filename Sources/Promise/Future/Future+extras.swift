public extension Future {
    convenience init(_ block: () throws -> Value) {
        self.init { resolver in
            resolver.resolve(block)
        }
    }
    
    static func fulfilled(with value: Value) -> Future {
        return Future { resolver in
            resolver.fulfill(with: value)
        }
    }
    
    static func rejected(with error: Error) -> Future {
        return Future { resolver in
            resolver.reject(with: error)
        }
    }
    
    func transform<T>(_ transform: @escaping (Resolver<T>, Value) throws -> Void) -> Future<T> {
        return .init { resolver in
            then { value in
                resolver.do { try transform(resolver, value) }
            }
            
            `catch`(resolver.reject)
        }
    }
    
    func map<T>(_ transform: @escaping (Value) throws -> T) -> Future<T> {
        return self.transform { resolver, value in
            resolver.fulfill(with: try transform(value))
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> Future<T>) -> Future<T> {
        return self.transform { resolver, value in
            resolver.observe(try transform(value))
        }
    }
    
    func async(_ context: @escaping ExecutionContext) -> Future {
        return Future { resolver in
            then { value in
                context { resolver.fulfill(with: value) }
            }
            
            `catch` { error in
                context { resolver.reject(with: error) }
            }
        }
    }
    
    func transformError(_ transform: @escaping (Resolver<Value>, Error) throws -> Void) -> Future {
        return .init { resolver in
            then(resolver.fulfill)
            
            `catch` { error in
                resolver.do { try transform(resolver, error) }
            }
        }
    }
    
    func mapError(_ transform: @escaping (Error) throws -> Error) -> Future {
        return self.transformError { _, error in
            throw try transform(error)
        }
    }
    
    func recover(_ recovery: @escaping (Error) throws -> Future) -> Future {
        return transformError { resolver, error in
            resolver.observe(try recovery(error))
        }
    }
    
    func `guard`(_ block: @escaping (Value) throws -> Void) -> Future {
        return map { value in
            try block(value)
            return value
        }
    }
}

public func race<T>(_ left: Future<T>, _ right: Future<T>) -> Future<T> {
    return Future { resolver in
        resolver.observe(left)
        resolver.observe(right)
    }
}

public func zip<A, B>(_ left: Future<A>, _ right: Future<B>) -> Future<(A, B)> {
    var leftValue: A?
    var rightValue: B?
    
    return Future { resolver in
        left.then { value in
            if let rightValue = rightValue {
                resolver.fulfill(with: (value, rightValue))
            } else {
                leftValue = value
            }
        }
        
        right.then { value in
            if let leftValue = leftValue {
                resolver.fulfill(with: (leftValue, value))
            } else {
                rightValue = value
            }
        }
        
        left.catch(resolver.reject)
        right.catch(resolver.reject)
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
    /// Wait for all the futures you give it to fulfill, and once they have, fulfill itself
    /// with the array of all fulfilled values. Preserves the order of the futures.
    func all<T>() -> Future<[T]> where Element == Future<T> {
        return reduce(.fulfilled(with: [])) {
            zip($0, $1).map { $0 + [$1] }
        }
    }
    
    /// Fulfills or rejects with the first future that completes
    /// (as opposed to waiting for all of them, like `.all` does).
    func race<T>() -> Future<T> where Element == Future<T> {
        return reduce(.pending, _race)
    }
}
