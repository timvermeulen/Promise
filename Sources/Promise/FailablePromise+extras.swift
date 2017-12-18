import Foundation

public extension FailablePromise {
    enum Error: Swift.Error {
        case checkFailed
        case timeout
    }
    
    static func fulfilled(with value: Value) -> FailablePromise {
        let (promise, fulfill, _) = makePromise()
        fulfill(value)
        return promise
    }
    
    static func rejected(with error: Swift.Error) -> FailablePromise {
        let (promise, _, reject) = makePromise()
        reject(error)
        return promise
    }
    
    func map<NewValue>(on context: ExecutionContext = .defaultBackground, _ transform: @escaping (Value) throws -> NewValue) -> FailablePromise<NewValue> {
        return .init(on: context) { fulfill, reject in
            self.then(on: context) { value in
                do {
                    fulfill(try transform(value))
                } catch {
                    reject(error)
                }
            }
            
            self.catch(on: context, reject)
        }
    }
    
    func flatMap<NewValue>(on context: ExecutionContext = .defaultBackground, _ transform: @escaping (Value) throws -> FailablePromise<NewValue>) -> FailablePromise<NewValue> {
        return .init(on: context) { fulfill, reject in
            self.then(on: context) { value in
                do {
                    let promise = try transform(value)
                    
                    promise.then(on: context, fulfill)
                    promise.catch(on: context, reject)
                } catch {
                    reject(error)
                }
            }
            
            self.catch(on: context, reject)
        }
    }
    
    func delayed(by delay: TimeInterval, on context: ExecutionContext = .defaultBackground) -> FailablePromise {
        return FailablePromise(on: context) { fulfill, reject in
            self.then(on: context) { value in
                context.execute(after: delay) { fulfill(value) }
            }
            
            self.catch(on: context) { error in
                context.execute(after: delay) { reject(error) }
            }
        }
    }
    
    /// This promise will be rejected after a delay.
    static func timeout(_ timeout: TimeInterval, on context: ExecutionContext = .defaultBackground) -> FailablePromise {
        return FailablePromise(on: context) { _, reject in
            FailablePromise<Void>.delay(timeout, on: context).then(on: context) {
                reject(Error.timeout)
            }
        }
    }
    
    static func retry(on context: ExecutionContext = .defaultBackground, count: Int, delay: TimeInterval, generate: @escaping () -> FailablePromise) -> FailablePromise {
        assert(count >= 0)
        guard count > 0 else { return generate() }
        
        return generate().recover(on: context) { _ in
            FailablePromise<Void>.delay(delay, on: context).flatMap {
                retry(on: context, count: count - 1, delay: delay, generate: generate)
            }
        }
    }
    
    static func kickoff(on context: ExecutionContext = .defaultBackground, _ block: @escaping () throws -> Value) -> FailablePromise {
        return FailablePromise(on: context) { fulfill, reject in
            do {
                fulfill(try block())
            } catch {
                reject(error)
            }
        }
    }
    
    static func zip<T, U>(_ first: FailablePromise, _ second: FailablePromise<T>, on context: ExecutionContext = .defaultBackground, with transform: @escaping (Value, T) throws -> U) -> FailablePromise<U> {
        return first.flatMap { x in
            second.map { y in try transform(x, y) }
        }
    }
    
    static func zip<T>(_ first: FailablePromise, _ second: FailablePromise<T>, on context: ExecutionContext = .defaultBackground) -> FailablePromise<(Value, T)> {
        return zip(first, second, on: context, with: { ($0, $1) })
    }
    
    func withTimeout(_ timeout: TimeInterval, on context: ExecutionContext = .defaultBackground) -> FailablePromise {
        return race(with: .timeout(timeout, on: context), on: context)
    }
    
    func recover(on context: ExecutionContext = .defaultBackground, recovery: @escaping (Swift.Error) throws -> FailablePromise) -> FailablePromise {
        return FailablePromise(on: context) { fulfill, reject in
            self.then(on: context, fulfill)
            
            self.catch(on: context) { error in
                do {
                    let recovered = try recovery(error)
                    recovered.then(on: context, fulfill)
                    recovered.catch(on: context, reject)
                } catch {
                    reject(error)
                }
            }
        }
    }
    
    func `guard`(on context: ExecutionContext = .defaultBackground, predicate: @escaping (Value) -> Bool) -> FailablePromise {
        return map(on: context) { value in
            guard predicate(value) else { throw Error.checkFailed }
            return value
        }
    }
    
    func race(with other: FailablePromise, on context: ExecutionContext = .defaultBackground) -> FailablePromise {
        return FailablePromise(on: context) { fulfill, reject in
            self.then(on: context, fulfill)
            self.catch(on: context, reject)
            
            other.then(on: context, fulfill)
            other.catch(on: context, reject)
        }
    }
}

public extension FailablePromise where Value == Void {
    /// Resolves itself after some delay.
    static func delay(_ delay: TimeInterval, on context: ExecutionContext = .defaultBackground) -> FailablePromise {
        return FailablePromise(on: context) { fulfill, _ in
            context.execute(after: delay) { fulfill(()) }
        }
    }
    
    static var fulfilled: FailablePromise {
        return .fulfilled(with: ())
    }
}

// TODO: remove this protocol once we have generic extensions
public protocol _Promise {
    associatedtype Value
    var _promise: FailablePromise<Value> { get }
}

extension FailablePromise: _Promise {
    public var _promise: FailablePromise { return self }
}

public extension Collection where Element: _Promise {
    /// Wait for all the promises you give it to fulfill, and once they have, fulfill itself
    /// with the array of all fulfilled values. Preserves the order of the promises.
    func all(on context: ExecutionContext = .defaultBackground) -> FailablePromise<[Element.Value]> {
        return reduce(.fulfilled(with: []), {
            return FailablePromise.zip($0, $1._promise, on: context).map(on: context) { return $0 + [$1] }
        })
    }
    
    /// Fulfills or rejects with the first promise that completes
    /// (as opposed to waiting for all of them, like `.all` does).
    func race(on context: ExecutionContext = .defaultBackground) -> FailablePromise<Element.Value> {
        return reduce(.pending, { $0.race(with: $1._promise, on: context) })
    }
}
