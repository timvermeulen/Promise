public extension FailablePromise {
    convenience init(_ block: () throws -> Value) {
        self.init { fulfill, reject in
            do {
                fulfill(try block())
            } catch {
                reject(error)
            }
        }
    }
    
    static var pending: FailablePromise {
        return FailablePromise()
    }
    
    static func fulfilled(with value: Value) -> FailablePromise {
        return FailablePromise { value }
    }
    
    static func rejected(with error: Error) -> FailablePromise {
        return FailablePromise { throw error }
    }
    
    func map<T>(_ transform: @escaping (Value) throws -> T) -> FailablePromise<T> {
        return .init { fulfill, reject in
            then { value in
                do {
                    fulfill(try transform(value))
                } catch {
                    reject(error)
                }
            }
            
            `catch`(reject)
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> FailablePromise<T>) -> FailablePromise<T> {
        return .init { fulfill, reject in
            then { value in
                do {
                    let promise = try transform(value)
                    
                    promise.then(fulfill)
                    promise.catch(reject)
                } catch {
                    reject(error)
                }
            }
            
            `catch`(reject)
        }
    }
    
    func recover(recovery: @escaping (Error) throws -> FailablePromise) -> FailablePromise {
        return FailablePromise { fulfill, reject in
            then(fulfill)
            
            `catch` { error in
                do {
                    let recovered = try recovery(error)
                    recovered.then(fulfill)
                    recovered.catch(reject)
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    func `guard`(_ block: @escaping (Value) throws -> Void) -> FailablePromise {
        return map { value in
            try block(value)
            return value
        }
    }
}

public func race<T>(_ left: FailablePromise<T>, _ right: FailablePromise<T>) -> FailablePromise<T> {
    return FailablePromise { fulfill, reject in
        left.then(fulfill)
        left.catch(reject)
        
        right.then(fulfill)
        right.catch(reject)
    }
}

public func zip<A, B>(_ left: FailablePromise<A>, _ right: FailablePromise<B>) -> FailablePromise<(A, B)> {
    return left.flatMap { x in
        right.map { y in (x, y) }
    }
}

public extension FailablePromise where Value == Void {
    static var fulfilled: FailablePromise {
        return .fulfilled(with: ())
    }
}

public protocol _FailablePromise {
    associatedtype Value
    var _promise: FailablePromise<Value> { get }
}

extension FailablePromise: _FailablePromise {
    public var _promise: FailablePromise { return self }
}

private func _race<T>(_ left: FailablePromise<T>, _ right: FailablePromise<T>) -> FailablePromise<T> {
    return race(left, right)
}

public extension Collection where Element: _FailablePromise {
    /// Wait for all the promises you give it to fulfill, and once they have, fulfill itself
    /// with the array of all fulfilled values. Preserves the order of the promises.
    func all() -> FailablePromise<[Element.Value]> {
        return reduce(.fulfilled(with: [])) {
            return zip($0, $1._promise).map { return $0 + [$1] }
        }
    }
    
    /// Fulfills or rejects with the first promise that completes
    /// (as opposed to waiting for all of them, like `.all` does).
    func race() -> FailablePromise<Element.Value> {
        return reduce(.pending, { _race($0, $1._promise) })
    }
}
