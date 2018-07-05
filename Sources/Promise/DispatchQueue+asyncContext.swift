import Foundation

extension DispatchQueue {
    var asyncContext: ExecutionContext {
        return { self.async(execute: $0) }
    }
}
