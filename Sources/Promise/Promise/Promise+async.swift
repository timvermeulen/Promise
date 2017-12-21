import Foundation

public extension Promise {
    func delayed(by delay: TimeInterval, on queue: DispatchQueue = .main) -> Promise {
        return Promise { fulfill in
            then { value in
                queue.asyncAfter(deadline: .now() + delay) { fulfill(value) }
            }
        }
    }
}
