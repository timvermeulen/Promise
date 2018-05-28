public final class BasicPromise<Value> {
    public let future: BasicFuture<Value>
    
    fileprivate init(future: BasicFuture<Value>) {
        self.future = future
    }
}

public extension BasicPromise {
    convenience init() {
        self.init(future: .pending)
    }
    
    func fulfill(with value: Value) {
        future.fulfill(with: value)
    }
}

extension BasicPromise where Value == Void {
    public func fulfill() {
        fulfill(with: ())
    }
}

public final class BasicFuture<Value> {
    private let state: Atomic<State>
    private let context: ((@escaping () -> Void) -> Void)?
    
    private init(context: ((@escaping () -> Void) -> Void)?) {
        self.state = Atomic(.pending(callbacks: []))
        self.context = context
    }
}

private extension BasicFuture {
    enum State {
        case pending(callbacks: [(Value) -> Void])
        case fulfilled(with: Value)
    }
    
    convenience init(context: ((@escaping () -> Void) -> Void)?, _ block: (BasicPromise<Value>) -> Void) {
        self.init(context: context)
        block(BasicPromise(future: self))
    }
    
    func perform(_ block: @escaping () -> Void) {
        if let context = context {
            context { block() }
        } else {
            block()
        }
    }
    
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
    
    convenience init(_ block: (BasicPromise<Value>) -> Void) {
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
    
    func async(_ context: @escaping (@escaping () -> Void) -> Void) -> BasicFuture {
        return .init(context: context) { promise in
            then(promise.fulfill)
        }
    }
}
