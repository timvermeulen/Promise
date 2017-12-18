import Foundation

public protocol ExecutionContextProtocol {
    func execute(work: @escaping () -> Void)
    func execute(after interval: TimeInterval, work: @escaping () -> Void)
}

extension DispatchQueue: ExecutionContextProtocol {
    public func execute(work: @escaping () -> Void) {
        async(execute: work)
    }
    
    public func execute(after interval: TimeInterval, work: @escaping () -> Void) {
        asyncAfter(deadline: .now() + interval, execute: work)
    }
}

public struct ExecutionContext {
    private let context: ExecutionContextProtocol
    
    public init(_ context: ExecutionContextProtocol) {
        self.context = context
    }
}

public extension ExecutionContext {
    func execute(work: @escaping () -> Void) {
        context.execute(work: work)
    }
    
    func execute(after interval: TimeInterval, work: @escaping () -> Void) {
        context.execute(after: interval, work: work)
    }
    
    static func queue(_ queue: DispatchQueue) -> ExecutionContext {
        return ExecutionContext(queue)
    }
    
    static let defaultForeground = ExecutionContext.queue(.main)
    static let defaultBackground = ExecutionContext.queue(.global())
}
