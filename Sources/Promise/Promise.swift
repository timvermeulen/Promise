public final class Promise<Value> {
    private var state = Atomic(State.pending(callbacks: []))
}

private extension Promise {
    indirect enum State {
        case pending(callbacks: [(Value) -> Void])
        case fulfilled(with: Value)
    }
    
    func fulfill(with value: Value) {
        let callbacks: [(Value) -> Void]? = state.mutate { state in
            guard case .pending(let callbacks) = state else { return nil }
            
            state = .fulfilled(with: value)
            return callbacks
        }
        
        callbacks?.forEach { $0(value) }
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
    
    func then(_ callback: @escaping (Value) -> Void) {
        let value: Value? = state.mutate { state in
            switch state {
            case .pending(var callbacks):
                callbacks.append(callback)
                state = .pending(callbacks: callbacks)
                return nil
            case .fulfilled(let value):
                return value
            }
        }
        
        if let value = value {
            callback(value)
        }
    }
}
