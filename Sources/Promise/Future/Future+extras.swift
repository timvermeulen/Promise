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

public func race<T>(_ lhs: Future<T>, _ rhs: Future<T>) -> Future<T> {
    return Future { resolver in
        resolver.observe(lhs)
        resolver.observe(rhs)
    }
}

public func raceValues<T>(_ lhs: Future<T>, _ rhs: Future<T>) -> Future<T> {
    var hasFailed = false
    
    return Future { resolver in
        func handleError(_ error: Error) {
            if hasFailed {
                resolver.reject(with: error)
            } else {
                hasFailed = true
            }
        }
        
        lhs
            .then(resolver.fulfill)
            .catch(handleError)
        
        rhs
            .then(resolver.fulfill)
            .catch(handleError)
    }
}

public func zip<A, B>(_ lhs: Future<A>, _ rhs: Future<B>) -> Future<(A, B)> {
    var leftValue: A?
    var rightValue: B?
    
    return Future { resolver in
        lhs.then { value in
            if let rightValue = rightValue {
                resolver.fulfill(with: (value, rightValue))
            } else {
                leftValue = value
            }
        }
        
        rhs.then { value in
            if let leftValue = leftValue {
                resolver.fulfill(with: (leftValue, value))
            } else {
                rightValue = value
            }
        }
        
        lhs.catch(resolver.reject)
        rhs.catch(resolver.reject)
    }
}

public extension Future where Value == Void {
    static var fulfilled: Future {
        return .fulfilled(with: ())
    }
}

private func _race<T>(_ lhs: Future<T>, _ rhs: Future<T>) -> Future<T> {
    return race(lhs, rhs)
}

private func _raceValues<T>(_ lhs: Future<T>, _ rhs: Future<T>) -> Future<T> {
    return raceValues(lhs, rhs)
}

public extension Sequence {
    func race<T>() -> Future<T> where Element == Future<T> {
        return reduce(.pending, _race)
    }
    
    func raceValues<T>() -> Future<T> where Element == Future<T> {
        return reduce(.pending, _raceValues)
    }
}
