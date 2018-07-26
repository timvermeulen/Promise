import Foundation

final class Atomic<Value> {
    private var _value: Value
    private let queue: DispatchQueue
    
    init(_ value: Value, queue: DispatchQueue = DispatchQueue(label: "\(Atomic.self)")) {
        self._value = value
        self.queue = queue
    }
}

extension Atomic {
    func access<T>(_ transform: (inout Value) -> T) -> T {
        return queue.sync { transform(&_value) }
    }
    
    var value: Value {
        return access { $0 }
    }
}
