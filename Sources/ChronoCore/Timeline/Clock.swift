public protocol Clock: Sendable {
    func now() -> Instant
}
