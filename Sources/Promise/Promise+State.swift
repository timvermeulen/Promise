extension Promise {
    indirect enum State {
        case pending
        case fulfilled(with: Value)
    }
}
