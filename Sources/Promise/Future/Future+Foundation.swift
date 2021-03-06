import Foundation

public extension Future {
    convenience init(
        asyncOn queue: DispatchQueue,
        _ process: @escaping (Promise<Value>) throws -> Void
    ) {
        self.init(asyncOn: queue.asyncContext, process)
    }
    
    convenience init(
        asyncOn queue: DispatchQueue,
        _ block: @escaping () throws -> Value
    ) {
        self.init(asyncOn: queue.asyncContext, block)
    }
    
    func on(_ queue: DispatchQueue) -> Future {
        return changeContext(queue.asyncContext)
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
    
    func await() throws -> Value {
        return try map(Result.value)
            .mapError(Result.error)
            .await()
            .unwrap()
    }
}

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public extension Future {
    func delayed(by interval: TimeInterval) -> Future {
        return on(.main).async { resolve in
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in resolve() }
        }
    }
    
    func timedOut(after delay: TimeInterval, withError error: Error) -> Future {
        return race(self, Future.rejected(with: error).delayed(by: delay))
    }
}

public extension URLSession {
    func dataTask(with request: URLRequest) -> Future<(data: Data, response: HTTPURLResponse)> {
        return Future { promise in
            let task = dataTask(with: request) { data, response, error in
                promise.resolve {
                    if let data = data, let response = response as? HTTPURLResponse {
                        return (data, response)
                    } else if let error = error {
                        throw error
                    } else {
                        preconditionFailure()
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func dataTask(with url: URL) -> Future<(data: Data, response: HTTPURLResponse)> {
        return dataTask(with: URLRequest(url: url))
    }
}
