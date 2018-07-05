public extension BasicFuture {
    convenience init(_ block: () -> Value) {
        self.init { $0.fulfill(with: block()) }
    }
    
    convenience init(asyncOn context: ExecutionContext, _ process: @escaping (BasicPromise<Value>) -> Void) {
        self.init { promise in
            context { process(promise) }
        }
    }
    
    convenience init(asyncOn context: ExecutionContext, _ block: @escaping () -> Value) {
        self.init(asyncOn: context) { promise in
            promise.fulfill(with: block())
        }
    }
    
    static func fulfilled(with value: Value) -> BasicFuture {
        return BasicFuture { value }
    }
    
    func transform<T>(_ transform: @escaping (BasicPromise<T>, Value) -> Void) -> BasicFuture<T> {
        return .init { promise in
            then { value in transform(promise, value) }
        }
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> BasicFuture<T> {
        return self.transform { promise, value in
            promise.fulfill(with: transform(value))
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> BasicFuture<T>) -> BasicFuture<T> {
        return self.transform { promise, value in
            transform(value).then(promise.fulfill)
        }
    }
    
    func async(_ context: @escaping ExecutionContext) -> BasicFuture {
        return transform { promise, value in
            context { promise.fulfill(with: value) }
        }
    }
}

func race<T>(_ lhs: BasicFuture<T>, _ rhs: BasicFuture<T>) -> BasicFuture<T> {
    return BasicFuture { promise in
        lhs.then(promise.fulfill)
        rhs.then(promise.fulfill)
    }
}

public func zip<A, B>(_ lhs: BasicFuture<A>, _ rhs: BasicFuture<B>) -> BasicFuture<(A, B)> {
    return lhs.flatMap { x in
        rhs.map { y in (x, y) }
    }
}

public extension BasicFuture where Value == Void {
    static var fulfilled: BasicFuture {
        return fulfilled(with: ())
    }
}

private func _race<T>(_ lhs: BasicFuture<T>, _ rhs: BasicFuture<T>) -> BasicFuture<T> {
    return race(lhs, rhs)
}

public extension Sequence {
    func race<T>() -> BasicFuture<T> where Element == BasicFuture<T> {
        return reduce(.pending, _race)
    }
}
