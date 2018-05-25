import Foundation

public extension BasicFuture {
    convenience init(asyncOn queue: DispatchQueue, _ block: @escaping () -> Value) {
        self.init { promise in
            queue.async { promise.fulfill(with: block()) }
        }
    }
    
    func on(_ queue: DispatchQueue) -> BasicFuture {
        return transform { promise, value in
            queue.async { promise.fulfill(with: value) }
        }
    }
    
    func asyncAfter(deadline: DispatchTime, on queue: DispatchQueue) -> BasicFuture {
        return transform { promise, value in
            queue.asyncAfter(deadline: deadline) { promise.fulfill(with: value) }
        }
    }
    
    func delayed(by interval: TimeInterval, on queue: DispatchQueue) -> BasicFuture {
        return transform { promise, value in
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                queue.async { promise.fulfill(with: value) }
            }
        }
    }
    
    func timed() -> BasicFuture<(value: Value, elapsedTime: TimeInterval)> {
        let start = Date()
        return map { ($0, Date().timeIntervalSince(start)) }
    }
}
