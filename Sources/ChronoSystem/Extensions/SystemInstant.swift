import ChronoCore

public extension Instant {
    @inlinable
    static func now() -> Self {
        SystemClock.shared.now()
    }
}
