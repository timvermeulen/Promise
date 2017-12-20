import Foundation

struct Atomic<Value> {
    private let queue = DispatchQueue(label: "queue")
    private var _value: Value
    
    init(_ value: Value) {
        _value = value
    }
}

extension Atomic {
    var value: Value {
        return queue.sync { _value }
    }
    
    mutating func mutate<T>(_ mutate: (inout Value) -> T) -> T {
        return queue.sync { mutate(&_value) }
    }
}
