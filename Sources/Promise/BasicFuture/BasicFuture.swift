public final class BasicFuture<Value> {
    private let state: Atomic<State>
    private let context: ExecutionContext
    
    private init(context: @escaping ExecutionContext) {
        self.state = Atomic(.pending(callbacks: []))
        self.context = context
    }
}

private extension BasicFuture {
    struct Callback {
        let changesContext: Bool
        let callback: (Value) -> Void
        
        func call(with value: Value, on context: ExecutionContext) {
            if changesContext {
                callback(value)
            } else {
                context { [callback] in callback(value) }
            }
        }
    }
    
    enum State {
        case pending(callbacks: [Callback])
        case fulfilled(with: Value)
    }
    
    convenience init(context: @escaping ExecutionContext, _ process: (BasicPromise<Value>) -> Void) {
        self.init(context: context)
        process(BasicPromise(future: self))
    }
    
    func addCallback(_ callback: Callback) {
        let value = state.access { state -> Value? in
            switch state {
            case .pending(var callbacks):
                state = .pending(callbacks: [])
                callbacks.append(callback)
                state = .pending(callbacks: callbacks)
                return nil
                
            case .fulfilled(let value):
                return value
            }
        }
        
        if let value = value {
            callback.call(with: value, on: context)
        }
    }
}

internal extension BasicFuture {
    func fulfill(with value: Value) {
        let callbacks: [Callback]? = state.access { state in
            guard case .pending(let callbacks) = state else { return nil }
            
            state = .fulfilled(with: value)
            return callbacks
        }
        
        callbacks?.forEach { $0.call(with: value, on: context) }
    }
    
    var testableValue: Value? {
        guard case .fulfilled(let value) = state.value else { return nil }
        return value
    }
}

public extension BasicFuture {
    static var pending: BasicFuture {
        return BasicFuture(context: defaultExecutionContext)
    }
    
    static func make() -> (future: BasicFuture, promise: BasicPromise<Value>) {
        let promise = BasicPromise<Value>(future: .pending)
        return (promise.future, promise)
    }
    
    convenience init(_ process: (BasicPromise<Value>) -> Void) {
        self.init(context: defaultExecutionContext, process)
    }
    
    @discardableResult
    func then(_ callback: @escaping (Value) -> Void) -> BasicFuture {
        addCallback(Callback(changesContext: false, callback: callback))
        return self
    }
    
    func changeContext(_ context: @escaping ExecutionContext) -> BasicFuture {
        return BasicFuture(context: context) { promise in
            addCallback(Callback(changesContext: true, callback: promise.fulfill))
        }
    }
}
