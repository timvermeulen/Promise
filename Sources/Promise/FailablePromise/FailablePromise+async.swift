import Foundation

public extension FailablePromise {
    func timedOut(after delay: TimeInterval, withError error: Error, on queue: DispatchQueue) -> FailablePromise {
        return race(self, FailablePromise.rejected(with: error).delayed(by: delay, on: queue))
    }
    
    func on(_ queue: DispatchQueue) -> FailablePromise {
        return FailablePromise { fulfill, reject in
            then { value in
                queue.async { fulfill(value) }
            }
            
            `catch` { error in
                queue.async { reject(error) }
            }
        }
    }
    
    func asyncAfter(deadline: DispatchTime, on queue: DispatchQueue) -> FailablePromise {
        return FailablePromise { fulfill, reject in
            then { value in
                queue.asyncAfter(deadline: deadline) {
                    fulfill(value)
                }
            }
            
            `catch` { error in
                queue.asyncAfter(deadline: deadline) {
                    reject(error)
                }
            }
        }
    }
    
    func delayed(by interval: TimeInterval, on queue: DispatchQueue) -> FailablePromise {
        return FailablePromise { fulfill, reject in
            then { value in
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                    queue.async { fulfill(value) }
                }
            }
            
            `catch` { error in
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                    queue.async { reject(error) }
                }
            }
        }
    }
    
    func timed() -> FailablePromise<(value: Value, elapsedTime: TimeInterval)> {
        let start = Date()
        return map { ($0, Date().timeIntervalSince(start)) }
    }
}
