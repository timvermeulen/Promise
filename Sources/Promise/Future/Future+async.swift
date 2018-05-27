import Foundation

public extension Future {
    convenience init(asyncOn queue: DispatchQueue, _ block: @escaping () throws -> Value) {
        self.init { promise in
            queue.async { promise.resolve(block) }
        }
    }
    
    func async(_ block: @escaping (_ resolve: @escaping () -> Void) -> Void) -> Future {
        return .init { promise in
            then { value in
                block { promise.fulfill(with: value) }
            }
            
            `catch` { error in
                block { promise.reject(with: error) }
            }
        }
    }
    
    func on(_ queue: DispatchQueue) -> Future {
        return async { resolve in
            queue.async(execute: resolve)
        }
    }
    
    func asyncAfter(deadline: DispatchTime, on queue: DispatchQueue) -> Future {
        return async { resolve in
            queue.asyncAfter(deadline: deadline, execute: resolve)
        }
    }
    
    func timed() -> Future<(value: Value, elapsedTime: TimeInterval)> {
        let start = Date()
        return map { ($0, Date().timeIntervalSince(start)) }
    }
}

@available(OSX 10.12, iOS 10.0, *)
public extension Future {
    func delayed(by interval: TimeInterval) -> Future {
        return async { resolve in
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in resolve() }
        }
    }
    
    func timedOut(after delay: TimeInterval, withError error: Error) -> Future {
        return race(self, Future.rejected(with: error).delayed(by: delay))
    }
}
