public final class BasicResolver<Value> {
    let future: BasicFuture<Value>
    
    init(future: BasicFuture<Value>) {
        self.future = future
    }
}

public extension BasicResolver {
    func fulfill(with value: Value) {
        future.fulfill(with: value)
    }
}

extension BasicResolver where Value == Void {
    public func fulfill() {
        fulfill(with: ())
    }
}
