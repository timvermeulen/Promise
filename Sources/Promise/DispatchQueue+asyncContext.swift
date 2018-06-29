import Foundation

extension DispatchQueue {
    var asyncContext: ExecutionContext {
        return { block in self.async(execute: block) }
    }
}
