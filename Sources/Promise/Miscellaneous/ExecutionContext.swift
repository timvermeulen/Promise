import Foundation

public typealias ExecutionContext = (@escaping () -> Void) -> Void

internal let defaultExecutionContext: ExecutionContext = { DispatchQueue.main.async(execute: $0) }
