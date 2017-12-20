import Foundation

struct Atomic<Value> {
    private var _value: Value
    private let queue: DispatchQueue
    
    init(_ value: Value, queue: DispatchQueue = DispatchQueue(label: "queue")) {
        self._value = value
        self.queue = queue
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
