public extension BasicFuture {
    convenience init(_ block: () -> Value) {
        self.init { $0.fulfill(with: block()) }
    }
    
    static func fulfilled(with value: Value) -> BasicFuture {
        return BasicFuture { value }
    }
    
    func transform<T>(_ transform: @escaping (BasicResolver<T>, Value) -> Void) -> BasicFuture<T> {
        return .init { resolver in
            then { value in transform(resolver, value) }
        }
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> BasicFuture<T> {
        return self.transform { resolver, value in
            resolver.fulfill(with: transform(value))
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> BasicFuture<T>) -> BasicFuture<T> {
        return self.transform { resolver, value in
            transform(value).then(resolver.fulfill)
        }
    }
    
    func async(_ context: @escaping ExecutionContext) -> BasicFuture {
        return transform { resolver, value in
            context { resolver.fulfill(with: value) }
        }
    }
}

func race<T>(_ left: BasicFuture<T>, _ right: BasicFuture<T>) -> BasicFuture<T> {
    return BasicFuture { resolver in
        left.then(resolver.fulfill)
        right.then(resolver.fulfill)
    }
}

public func zip<A, B>(_ left: BasicFuture<A>, _ right: BasicFuture<B>) -> BasicFuture<(A, B)> {
    return left.flatMap { x in
        right.map { y in (x, y) }
    }
}

public extension BasicFuture where Value == Void {
    static var fulfilled: BasicFuture {
        return fulfilled(with: ())
    }
}

private func _race<T>(_ left: BasicFuture<T>, _ right: BasicFuture<T>) -> BasicFuture<T> {
    return race(left, right)
}

public extension Sequence {
    func race<T>() -> BasicFuture<T> where Element == BasicFuture<T> {
        return reduce(.pending, _race)
    }
}
