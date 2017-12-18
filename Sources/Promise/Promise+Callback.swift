extension Promise {
    struct Callback {
        let context: ExecutionContext
        let handler: (Value) -> Void
        
        func call(with value: Value) {
            context.execute {
                self.handler(value)
            }
        }
    }
}
