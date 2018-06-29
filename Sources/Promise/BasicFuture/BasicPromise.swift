public final class BasicPromise<Value> {
    let future: BasicFuture<Value>
    
    init(future: BasicFuture<Value>) {
        self.future = future
    }
}

public extension BasicPromise {
    func fulfill(with value: Value) {
        future.fulfill(with: value)
    }
}

public extension BasicPromise where Value == Void {
    func fulfill() {
        fulfill(with: ())
    }
}
