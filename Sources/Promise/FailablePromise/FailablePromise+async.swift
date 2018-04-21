import Foundation

public extension FailablePromise {
    func timedOut(after delay: TimeInterval, withError error: Error, on queue: DispatchQueue) -> FailablePromise {
        return race(self, FailablePromise.rejected(with: error).delayed(by: delay, on: queue))
    }
    
    func sync(on queue: DispatchQueue) -> FailablePromise {
        return FailablePromise { fulfill, reject in
            then { value in
                queue.sync { fulfill(value) }
            }
            
            `catch` { error in
                queue.sync { reject(error) }
            }
        }
    }
    
    func async(on queue: DispatchQueue) -> FailablePromise {
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
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in fulfill(value) }
            }
            
            `catch` { error in
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in reject(error) }
            }
        }
    }
    
    func timed(withInterval interval: TimeInterval) -> FailablePromise<(value: Value, beforeExpiry: Bool)> {
        let timer = FailablePromise<Void>.fulfilled.delayed(by: interval, on: .global())
        
        return race(
            zip(self, timer).map { ($0.0, false) },
            map { ($0, true) }
        )
    }
}
