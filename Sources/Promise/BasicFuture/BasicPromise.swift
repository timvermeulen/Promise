public final class BasicPromise<Value> {
    public let future: BasicFuture<Value>
    private let resolver: BasicResolver<Value>
    
    init(future: BasicFuture<Value>) {
        self.future = future
        self.resolver = BasicResolver(future: future)
    }
}

public extension BasicPromise {
    convenience init() {
        self.init(future: .pending)
    }
    
    func fulfill(with value: Value) {
        resolver.fulfill(with: value)
    }
}

public extension BasicPromise where Value == Void {
    func fulfill() {
        resolver.fulfill()
    }
}
