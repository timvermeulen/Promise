enum Result<Value> {
    case value(Value)
    case error(Error)
}

extension Result {
    func unwrap() throws -> Value {
        switch self {
        case .value(let value):
            return value
        case .error(let error):
            throw error
        }
    }
}
