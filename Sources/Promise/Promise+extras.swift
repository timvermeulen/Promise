extension Promise {
    func map<NewValue>(on context: ExecutionContext = .defaultBackground, _ transform: @escaping (Value) -> NewValue) -> Promise<NewValue> {
        return .init { fulfill in
            self.then(on: context) { value in
                fulfill(transform(value))
            }
        }
    }
    
    func race(with other: Promise, on context: ExecutionContext = .defaultBackground) -> Promise {
        return Promise { fulfill in
            self.then(on: context, handler: fulfill)
            other.then(on: context, handler: fulfill)
        }
    }
}
