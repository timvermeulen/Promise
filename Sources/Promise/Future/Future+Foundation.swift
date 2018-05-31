import Foundation

public extension Future {
    convenience init(asyncOn queue: DispatchQueue, _ block: @escaping () throws -> Value) {
        self.init { resolver in
            queue.async { resolver.resolve(block) }
        }
    }
    
    func on(_ queue: DispatchQueue) -> Future {
        return changeContext { resolve in
            queue.async(execute: resolve)
        }
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
}

@available(OSX 10.12, iOS 10.0, *)
public extension Future {
    func delayed(by interval: TimeInterval) -> Future {
        return async { resolve in
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in resolve() }
        }
    }
    
    func timedOut(after delay: TimeInterval, withError error: Error) -> Future {
        return race(self, Future.rejected(with: error).delayed(by: delay))
    }
}

public extension URLSession {
    func dataTask(with request: URLRequest) -> Future<(data: Data, response: HTTPURLResponse)> {
        return Future { resolver in
            let task = dataTask(with: request) { data, response, error in
                resolver.resolve {
                    if let data = data, let response = response as? HTTPURLResponse {
                        return (data, response)
                    } else if let error = error {
                        throw error
                    } else {
                        fatalError()
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
