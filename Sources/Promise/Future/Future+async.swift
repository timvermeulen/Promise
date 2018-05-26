import Foundation

public extension Future {
    convenience init(asyncOn queue: DispatchQueue, _ block: @escaping () throws -> Value) {
        self.init { promise in
            queue.async {
                do {
                    promise.fulfill(with: try block())
                } catch {
                    promise.reject(with: error)
                }
            }
        }
    }
    
    func timedOut(after delay: TimeInterval, withError error: Error) -> Future {
        return race(self, Future.rejected(with: error).delayed(by: delay))
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
    
    func delayed(by interval: TimeInterval) -> Future {
        return async { resolve in
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in resolve() }
        }
    }
    
    func timed() -> Future<(value: Value, elapsedTime: TimeInterval)> {
        let start = Date()
        return map { ($0, Date().timeIntervalSince(start)) }
    }
}
