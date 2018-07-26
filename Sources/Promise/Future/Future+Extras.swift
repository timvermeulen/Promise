public extension Future {
    convenience init(_ block: () throws -> Value) {
        self.init { promise in
            promise.resolve(block)
        }
    }
    
    convenience init(
        asyncOn context: ExecutionContext,
        _ process: @escaping (Promise<Value>) throws -> Void
    ) {
        self.init { promise in
            context {
                promise.do { try process(promise) }
            }
        }
    }
    
    convenience init(asyncOn context: ExecutionContext, _ block: @escaping () throws -> Value) {
        self.init(asyncOn: context) { promise in
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
    
    func transform<T>(_ process: @escaping (Promise<T>, Value) throws -> Void) -> Future<T> {
        return .init { promise in
            then { value in
                promise.do { try process(promise, value) }
            }.catch(promise.reject)
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
    
    func async(_ context: @escaping ExecutionContext) -> Future {
        return Future { promise in
            then { value in
                context { promise.fulfill(with: value) }
            }.catch { error in
                context { promise.reject(with: error) }
            }
        }
    }
    
    func transformError(_ process: @escaping (Promise<Value>, Error) throws -> Void) -> Future {
        return .init { promise in
            then(promise.fulfill).catch { error in
                promise.do { try process(promise, error) }
            }
        }
    }
    
    func transformError(
        _ process: @escaping (BasicPromise<Value>, Error) -> Void
    ) -> BasicFuture<Value> {
        return .init { promise in
            then(promise.fulfill).catch { error in
                process(promise, error)
            }
        }
    }
    
    func mapError(_ transform: @escaping (Error) throws -> Error) -> Future {
        return self.transformError { _, error in
            throw try transform(error)
        }
    }
    
    func recover(_ transform: @escaping (Error) throws -> Future) -> Future {
        return transformError { promise, error in
            promise.observe(try transform(error))
        }
    }
    
    func recover(_ transform: @escaping (Error) -> Value) -> BasicFuture<Value> {
        return transformError { promise, error in
            promise.fulfill(with: transform(error))
        }
    }
    
    func `guard`(_ process: @escaping (Value) throws -> Void) -> Future {
        return map { value in
            try process(value)
            return value
        }
    }
    
    func ingoringValue() -> Future<Void> {
        return map { _ in }
    }
}

public func race<T>(_ lhs: Future<T>, _ rhs: Future<T>) -> Future<T> {
    return Future { promise in
        promise.observe(lhs)
        promise.observe(rhs)
    }
}

public func raceValues<T>(_ lhs: Future<T>, _ rhs: Future<T>) -> Future<T> {
    var hasFailed = false
    
    return Future { promise in
        func handleError(_ error: Error) {
            if hasFailed {
                promise.reject(with: error)
            } else {
                hasFailed = true
            }
        }
        
        lhs.then(promise.fulfill).catch(handleError)
        rhs.then(promise.fulfill).catch(handleError)
    }
}

public func zip<A, B>(_ lhs: Future<A>, _ rhs: Future<B>) -> Future<(A, B)> {
    var leftValue: A?
    var rightValue: B?
    
    return Future { promise in
        lhs.then { value in
            if let rightValue = rightValue {
                promise.fulfill(with: (value, rightValue))
            } else {
                leftValue = value
            }
        }.catch(promise.reject)
        
        rhs.then { value in
            if let leftValue = leftValue {
                promise.fulfill(with: (leftValue, value))
            } else {
                rightValue = value
            }
        }.catch(promise.reject)
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
