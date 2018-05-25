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
    
    func timedOut(after delay: TimeInterval, withError error: Error, on queue: DispatchQueue) -> Future {
        return race(self, Future.rejected(with: error).delayed(by: delay, on: queue))
    }
    
    func on(_ queue: DispatchQueue) -> Future {
        return Future { promise in
            then { value in
                queue.async { promise.fulfill(with: value) }
            }
            
            `catch` { error in
                queue.async { promise.reject(with: error) }
            }
        }
    }
    
    func asyncAfter(deadline: DispatchTime, on queue: DispatchQueue) -> Future {
        return Future { promise in
            then { value in
                queue.asyncAfter(deadline: deadline) {
                    promise.fulfill(with: value)
                }
            }
            
            `catch` { error in
                queue.asyncAfter(deadline: deadline) {
                    promise.reject(with: error)
                }
            }
        }
    }
    
    func delayed(by interval: TimeInterval, on queue: DispatchQueue) -> Future {
        return Future { promise in
            then { value in
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                    queue.async { promise.fulfill(with: value) }
                }
            }
            
            `catch` { error in
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                    queue.async { promise.reject(with: error) }
                }
            }
        }
    }
    
    func timed() -> Future<(value: Value, elapsedTime: TimeInterval)> {
        let start = Date()
        return map { ($0, Date().timeIntervalSince(start)) }
    }
}
