public extension Promise {
    convenience init(_ block: () -> Value) {
        self.init { $0(block()) }
    }
    
    static func fulfilled(with value: Value) -> Promise {
        return Promise { value }
    }
    
    static var pending: Promise {
        return Promise()
    }
    
    func transform<T>(_ transform: @escaping (@escaping (T) -> Void, Value) -> Void) -> Promise<T> {
        return .init { fulfill in
            then { value in transform(fulfill, value) }
        }
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> Promise<T> {
        return self.transform { fulfill, value in
            fulfill(transform(value))
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> Promise<T>) -> Promise<T> {
        return self.transform { fulfill, value in
            transform(value).then(fulfill)
        }
    }
}

func race<T>(_ left: Promise<T>, _ right: Promise<T>) -> Promise<T> {
    return Promise { fulfill in
        left.then(fulfill)
        right.then(fulfill)
    }
}

public func zip<A, B>(_ left: Promise<A>, _ right: Promise<B>) -> Promise<(A, B)> {
    return left.flatMap { x in
        right.map { y in (x, y) }
    }
}

public extension Promise where Value == Void {
    static var fulfilled: Promise {
        return fulfilled(with: ())
    }
}

// TODO: remove this protocol once we have generic extensions
public protocol _Promise {
    associatedtype Value
    var _promise: Promise<Value> { get }
}

private func _race<T>(_ left: Promise<T>, _ right: Promise<T>) -> Promise<T> {
    return race(left, right)
}

public extension Collection where Element: _Promise {
    func all() -> Promise<[Element.Value]> {
        return reduce(.fulfilled(with: [])) {
            zip($0, $1._promise).map { $0 + [$1] }
        }
    }
    
    func race() -> Promise<Element.Value> {
        return reduce(.pending, { _race($0, $1._promise) })
    }
}
