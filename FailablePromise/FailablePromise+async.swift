import Foundation

public extension FailablePromise {
    func timedOut(after delay: TimeInterval, withError error: Error, on queue: DispatchQueue = .main) -> FailablePromise {
        return racing(with: FailablePromise.rejected(with: error).delayed(by: delay, on: queue))
    }
    
    func delayed(by delay: TimeInterval, on queue: DispatchQueue = .main) -> FailablePromise {
        return FailablePromise { fulfill, reject in
            then { value in
                queue.asyncAfter(deadline: .now() + delay) {
                    fulfill(value)
                }
            }
            
            `catch` { error in
                queue.asyncAfter(deadline: .now() + delay) {
                    reject(error)
                }
            }
        }
    }
}
