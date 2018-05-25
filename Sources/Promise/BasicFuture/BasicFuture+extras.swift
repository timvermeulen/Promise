public extension BasicFuture {
    convenience init(_ block: () -> Value) {
        self.init { $0.fulfill(with: block()) }
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
}

func race<T>(_ left: BasicFuture<T>, _ right: BasicFuture<T>) -> BasicFuture<T> {
    return BasicFuture { promise in
        left.then(promise.fulfill)
        right.then(promise.fulfill)
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

// TODO: remove this protocol once we have parameterized extensions
public protocol _Promise {
    associatedtype Value
    var _promise: BasicFuture<Value> { get }
}

private func _race<T>(_ left: BasicFuture<T>, _ right: BasicFuture<T>) -> BasicFuture<T> {
    return race(left, right)
}

public extension Collection where Element: _Promise {
    func all() -> BasicFuture<[Element.Value]> {
        return reduce(.fulfilled(with: [])) {
            zip($0, $1._promise).map { $0 + [$1] }
        }
    }
    
    func race() -> BasicFuture<Element.Value> {
        return reduce(.pending, { _race($0, $1._promise) })
    }
}
