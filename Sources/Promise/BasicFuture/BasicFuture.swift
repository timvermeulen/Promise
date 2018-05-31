public final class BasicFuture<Value> {
    private let state: Atomic<State>
    private let context: ExecutionContext?
    
    private init(context: ExecutionContext?) {
        self.state = Atomic(.pending(callbacks: []))
        self.context = context
    }
}

private extension BasicFuture {
    enum State {
        case pending(callbacks: [(Value) -> Void])
        case fulfilled(with: Value)
    }
    
    convenience init(context: ExecutionContext?, _ block: (BasicResolver<Value>) -> Void) {
        self.init(context: context)
        block(BasicResolver(future: self))
    }
    
    func perform(_ block: @escaping () -> Void) {
        if let context = context {
            context { block() }
        } else {
            block()
        }
    }
}

internal extension BasicFuture {
    func fulfill(with value: Value) {
        let callbacks: [(Value) -> Void]? = state.access { state in
            guard case .pending(let callbacks) = state else { return nil }
            
            state = .fulfilled(with: value)
            return callbacks
        }
        
        callbacks?.forEach { callback in
            perform { callback(value) }
        }
    }
}

public extension BasicFuture {
    static var pending: BasicFuture {
        return BasicFuture(context: nil)
    }
    
    convenience init(_ block: (BasicResolver<Value>) -> Void) {
        self.init(context: nil, block)
    }
    
    @discardableResult
    func then(_ callback: @escaping (Value) -> Void) -> BasicFuture {
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
            perform { callback(value) }
        }
        
        return self
    }
    
    func changeContext(_ context: @escaping ExecutionContext) -> BasicFuture {
        return BasicFuture(context: context) { resolver in
            then(resolver.fulfill)
        }
    }
}
