import Foundation

public extension BasicFuture {
    convenience init(asyncOn queue: DispatchQueue, _ block: @escaping () -> Value) {
        self.init { promise in
            queue.async { promise.fulfill(with: block()) }
        }
    }
    
    func async(_ block: @escaping (_ resolve: @escaping () -> Void) -> Void) -> BasicFuture {
        return transform { promise, value in
            block { promise.fulfill(with: value) }
        }
    }
    
    func on(_ queue: DispatchQueue) -> BasicFuture {
        return async { resolve in
            queue.async(execute: resolve)
        }
    }
    
    func asyncAfter(deadline: DispatchTime, on queue: DispatchQueue) -> BasicFuture {
        return async { resolve in
            queue.asyncAfter(deadline: deadline, execute: resolve)
        }
    }
    
    func timed() -> BasicFuture<(value: Value, elapsedTime: TimeInterval)> {
        let start = Date()
        return map { ($0, Date().timeIntervalSince(start)) }
    }
    
    @available(macOS 10.12, iOS 10.0, *)
    func delayed(by interval: TimeInterval) -> BasicFuture {
        return async { resolve in
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in resolve() }
        }
    }
}
