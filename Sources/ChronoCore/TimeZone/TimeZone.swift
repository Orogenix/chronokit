public protocol TimeZoneProtocol: Equatable, Hashable, Sendable {
    /// The name of the timezone (e.g., "UTC", "+07:00")
    var identifier: String { get }

    /// Returns the offset in Duration from UTC for a specific UTC timestamp.
    func offset(for instant: Instant) -> Duration
}
