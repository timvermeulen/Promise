public extension Future {
    convenience init(_ block: () throws -> Value) {
        self.init { promise in
            do {
                promise.fulfill(with: try block())
            } catch {
                promise.reject(with: error)
            }
        }
    }
    
    static func fulfilled(with value: Value) -> Future {
        return Future { value }
    }
    
    static func rejected(with error: Error) -> Future {
        return Future { throw error }
    }
    
    func transform<T>(_ transform: @escaping (Promise<T>, Value) throws -> Void) -> Future<T> {
        return .init { promise in
            then { value in
                do {
                    try transform(promise, value)
                } catch {
                    promise.reject(with: error)
                }
            }
            
            `catch`(promise.reject)
        }
    }
    
    func map<T>(_ transform: @escaping (Value) throws -> T) -> Future<T> {
        return self.transform { promise, value in
            promise.fulfill(with: try transform(value))
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> Future<T>) -> Future<T> {
        return self.transform { promise, value in
            let future = try transform(value)
            
            future.then(promise.fulfill)
            future.catch(promise.reject)
        }
    }
    
    func recover(_ recovery: @escaping (Error) throws -> Future) -> Future {
        return Future { promise in
            then(promise.fulfill)
            
            `catch` { error in
                do {
                    let recovered = try recovery(error)
                    recovered.then(promise.fulfill)
                    recovered.catch(promise.reject)
                } catch {
                    promise.reject(with: error)
                }
            }
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
    return Future { promise in
        left.then(promise.fulfill)
        left.catch(promise.reject)
        
        right.then(promise.fulfill)
        right.catch(promise.reject)
    }
}

public func zip<A, B>(_ left: Future<A>, _ right: Future<B>) -> Future<(A, B)> {
    return left.flatMap { x in
        right.map { y in (x, y) }
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
    /// Wait for all the promises you give it to fulfill, and once they have, fulfill itself
    /// with the array of all fulfilled values. Preserves the order of the promises.
    func all<T>() -> Future<[T]> where Element == Future<T> {
        return reduce(.fulfilled(with: [])) {
            zip($0, $1).map { $0 + [$1] }
        }
    }
    
    /// Fulfills or rejects with the first promise that completes
    /// (as opposed to waiting for all of them, like `.all` does).
    func race<T>() -> Future<T> where Element == Future<T> {
        return reduce(.pending, _race)
    }
}
