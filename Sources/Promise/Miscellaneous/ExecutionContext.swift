import Foundation

public typealias ExecutionContext = (@escaping () -> Void) -> Void

internal let defaultExecutionContext = DispatchQueue.main.asyncContext
