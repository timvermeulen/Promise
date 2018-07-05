enum Result<Value> {
    case success(Value)
    case failure(Error)
}

extension Result {
    func unwrap() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
