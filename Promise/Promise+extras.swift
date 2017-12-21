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
    
    func map<T>(_ transform: @escaping (Value) -> T) -> Promise<T> {
        return .init { fulfill in
            then { value in
                fulfill(transform(value))
            }
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> Promise<T>) -> Promise<T> {
        return .init { fulfill in
            then { value in
                transform(value).then(fulfill)
            }
        }
    }
    
    func racing(with other: Promise) -> Promise {
        return Promise { fulfill in
            then(fulfill)
            other.then(fulfill)
        }
    }
    
    func zipped<T>(with other: Promise<T>) -> Promise<(Value, T)> {
        return flatMap { x in
            other.map { y in (x, y) }
        }
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

public extension Collection where Element: _Promise {
    func all() -> Promise<[Element.Value]> {
        return reduce(.fulfilled(with: []), {
            $0.zipped(with: $1._promise).map { $0 + [$1] }
        })
    }
    
    func race() -> Promise<Element.Value> {
        return reduce(.pending, { $0.racing(with: $1._promise) })
    }
}
