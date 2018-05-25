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
    
    private init() {
        state = Atomic(.pending(callbacks: []))
    }
}

private extension BasicFuture {
    enum State {
        case pending(callbacks: [(Value) -> Void])
        case fulfilled(with: Value)
    }
    
    func fulfill(with value: Value) {
        let callbacks: [(Value) -> Void]? = state.access { state in
            guard case .pending(let callbacks) = state else { return nil }
            
            state = .fulfilled(with: value)
            return callbacks
        }
        
        callbacks?.forEach { $0(value) }
    }
}

public extension BasicFuture {
    static var pending: BasicFuture {
        return BasicFuture()
    }
    
    convenience init(_ block: (BasicPromise<Value>) -> Void) {
        self.init()
        block(BasicPromise(future: self))
    }
    
    func then(_ callback: @escaping (Value) -> Void) {
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
            callback(value)
        }
    }
}
