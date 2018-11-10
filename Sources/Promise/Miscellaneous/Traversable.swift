// see https://hackage.haskell.org/package/base/docs/Data-Traversable.html

public extension Optional {
    func traverse<T>(_ transform: (Wrapped) -> BasicFuture<T>) -> BasicFuture<T?> {
        return BasicFuture { promise in
            if let wrapped = self {
                transform(wrapped).map { $0 }.then(promise.fulfill)
            } else {
                promise.fulfill(with: nil)
            }
        }
    }
    
    func sequence<T>() -> BasicFuture<T?> where Wrapped == BasicFuture<T> {
        return traverse { $0 }
    }
    
    func traverse<T>(_ transform: (Wrapped) throws -> Future<T>) -> Future<T?> {
        return Future { promise in
            if let wrapped = self {
                promise.observe(try transform(wrapped).map { $0 })
            } else {
                promise.fulfill(with: nil)
            }
        }
    }
    
    func sequence<T>() -> Future<T?> where Wrapped == Future<T> {
        return traverse { $0 }
    }
}

public extension Sequence {
    func traverse<T>(_ transform: (Element) -> BasicFuture<T>) -> BasicFuture<[T]> {
        return reduce(.fulfilled(with: [])) {
            zip($0, transform($1)).map { $0 + [$1] }
        }
    }
    
    func sequence<T>() -> BasicFuture<[T]> where Element == BasicFuture<T> {
        return traverse { $0 }
    }
    
    func traverse<T>(_ transform: (Element) throws -> Future<T>) -> Future<[T]> {
        do {
            return try reduce(.fulfilled(with: [])) {
                zip($0, try transform($1)).map { $0 + [$1] }
            }
        } catch {
            return .rejected(with: error)
        }
    }
    
    func sequence<T>() -> Future<[T]> where Element == Future<T> {
        return traverse { $0 }
    }
    
    func traverse(_ transform: (Element) -> BasicFuture<Void>) -> BasicFuture<Void> {
        return traverse(transform).map { (_: [Void]) in }
    }
    
    func traverse(_ transform: (Element) -> Future<Void>) -> Future<Void> {
        return traverse(transform).map { (_: [Void]) in }
    }
}

public extension Sequence where Element == BasicFuture<Void> {
    func sequence() -> BasicFuture<Void> {
        return sequence().map { (_: [Void]) in }
    }
}

public extension Sequence where Element == Future<Void> {
    func sequence() -> Future<Void> {
        return sequence().map { (_: [Void]) in }
    }
}
