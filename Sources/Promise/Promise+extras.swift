extension Promise {
    func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Promise<NewValue> {
        return .init { fulfill in
            self.then { value in
                fulfill(transform(value))
            }
        }
    }
    
    func race(with other: Promise) -> Promise {
        return Promise { fulfill in
            self.then(fulfill)
            other.then(fulfill)
        }
    }
}
