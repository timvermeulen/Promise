public final class BasicPromise<Value> {
    public let future: BasicFuture<Value>
    
    init(future: BasicFuture<Value>) {
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
