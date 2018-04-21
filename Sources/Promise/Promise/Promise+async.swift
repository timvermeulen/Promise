import Foundation

public extension Promise {
    func sync(on queue: DispatchQueue) -> Promise {
        return transform { fulfill, value in
            queue.sync { fulfill(value) }
        }
    }
    
    func async(on queue: DispatchQueue) -> Promise {
        return transform { fulfill, value in
            queue.async { fulfill(value) }
        }
    }
    
    func asyncAfter(deadline: DispatchTime, on queue: DispatchQueue) -> Promise {
        return transform { fulfill, value in
            queue.asyncAfter(deadline: deadline) { fulfill(value) }
        }
    }
    
    func delayed(by interval: TimeInterval, on queue: DispatchQueue) -> Promise {
        return transform { fulfill, value in
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                queue.async {fulfill(value) }
            }
        }
    }
    
    func timed() -> Promise<(value: Value, elapsedTime: TimeInterval)> {
        let start = Date()
        return map { ($0, Date().timeIntervalSince(start)) }
    }
}
