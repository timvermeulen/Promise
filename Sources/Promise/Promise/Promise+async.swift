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
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in fulfill(value) }
        }
    }
    
    func timed(withInterval interval: TimeInterval) -> Promise<(value: Value, beforeExpiry: Bool)> {
        let timer = Promise<Void>.fulfilled.delayed(by: interval, on: .global())
        
        return race(
            zip(self, timer).map { ($0.0, false) },
            map { ($0, true) }
        )
    }
}
