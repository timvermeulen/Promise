import Foundation

public final class Promise<Value> {
    private var state = State.pending
    private let lockQueue = DispatchQueue(label: "promise_lock_queue", qos: .userInitiated)
    private var callbacks: [Callback] = []
    
    private init() {}
}

private extension Promise {
    func fulfill(with value: Value) {
        // this needs to be done synchronously because `async`
        // does not guarantee any particular order
        lockQueue.sync {
            guard case .pending = state else { return }
            
            state = .fulfilled(with: value)
            callbacks.forEach { $0.call(with: value) }
            callbacks.removeAll()
        }
    }
    
    func addCallback(_ callback: Callback) {
        lockQueue.async {
            switch self.state {
            case .pending:
                self.callbacks.append(callback)
            case .fulfilled(let value):
                callback.call(with: value)
            }
        }
    }
}

public extension Promise {
    convenience init(_ work: @escaping (_ fulfill: @escaping (Value) -> Void) -> Void) {
        self.init()
        work(fulfill)
    }
    
    static func makePromise() -> (promise: Promise, fulfill: (Value) -> Void) {
        let promise = Promise()
        return (promise, promise.fulfill)
    }
    
    func then(on context: ExecutionContext = .defaultForeground, handler: @escaping (Value) -> Void) {
        addCallback(Callback(context: context, handler: handler))
    }
}
