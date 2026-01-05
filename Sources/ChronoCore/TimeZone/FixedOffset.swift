import ChronoMath

public struct FixedOffset: Equatable, Hashable, Sendable {
    /// The offset in seconds east of UTC.
    /// e.g., +02:00 is 7200. -05:00 is -18000.
    @usableFromInline
    let duration: Duration

    @inlinable
    public init(_ duration: Duration) {
        let totalNanos = duration.seconds * NanoSeconds.perSecond64 + Int64(duration.nanoseconds)
        precondition(
            totalNanos >= -NanoSeconds.perDay64 && totalNanos <= NanoSeconds.perDay64,
            "seconds is out of bounds",
        )
        self.duration = duration
    }

    @inlinable
    public init(seconds: Int) {
        precondition(
            seconds >= -Seconds.perDay && seconds <= Seconds.perDay,
            "seconds is out of bounds",
        )
        duration = Duration(seconds: Int64(seconds))
    }

    @inlinable
    public init?(isoSeconds: Int) {
        // ISO8601 bounds: -14 hours to +14 hours
        guard isoSeconds >= -(14 * Seconds.perHour),
              isoSeconds <= (14 * Seconds.perHour) else { return nil }
        duration = Duration(seconds: Int64(isoSeconds))
    }

    /// Create from hours and minutes (e.g., +7 hours, 0 minutes)
    @inlinable
    public init?(hours: Int, minutes: Int, sign: TimeZoneSign = .plus) {
        guard minutes >= 0, minutes < 60,
              hours >= 0, hours <= 24,
              !(hours == 24 && minutes != 0) else { return nil }

        let seconds = sign.apply(to: abs(hours) * Seconds.perHour + abs(minutes) * Seconds.perMinute)

        self.init(seconds: seconds)
    }
}

public extension FixedOffset {
    @inlinable
    static var utc: Self {
        Self(seconds: 0)
    }

    @inlinable
    static func eastUTC(_ seconds: Int) -> Self? {
        guard seconds >= 0 else { return nil }
        return Self(seconds: seconds)
    }

    @inlinable
    static func westUTC(_ seconds: Int) -> Self? {
        guard seconds >= 0 else { return nil }
        return Self(seconds: -seconds)
    }

    @inlinable
    static func nanoseconds(_ value: Int) -> Self {
        let duration: Duration = .nanoseconds(value)
        return Self(duration)
    }

    @inlinable
    static func nanoseconds(_ value: Int64) -> Self {
        let duration: Duration = .nanoseconds(value)
        return Self(duration)
    }

    @inlinable
    static func microseconds(_ value: Int) -> Self {
        let duration: Duration = .microseconds(value)
        return Self(duration)
    }

    @inlinable
    static func microseconds(_ value: Int64) -> Self {
        let duration: Duration = .microseconds(value)
        return Self(duration)
    }

    @inlinable
    static func milliseconds(_ value: Int) -> Self {
        let duration: Duration = .milliseconds(value)
        return Self(duration)
    }

    @inlinable
    static func milliseconds(_ value: Int64) -> Self {
        let duration: Duration = .milliseconds(value)
        return Self(duration)
    }

    @inlinable
    static func seconds(_ value: Int) -> Self {
        let duration: Duration = .seconds(value)
        return Self(duration)
    }

    @inlinable
    static func seconds(_ value: Int64) -> Self {
        let duration: Duration = .seconds(value)
        return Self(duration)
    }

    @inlinable
    static func seconds(_ value: Double) -> Self {
        let duration: Duration = .seconds(value)
        return Self(duration)
    }

    @inlinable
    static func minutes(_ value: Int) -> Self {
        let duration: Duration = .minutes(value)
        return Self(duration)
    }

    @inlinable
    static func minutes(_ value: Int64) -> Self {
        let duration: Duration = .minutes(value)
        return Self(duration)
    }

    @inlinable
    static func hours(_ value: Int) -> Self {
        let duration: Duration = .hours(value)
        return Self(duration)
    }

    @inlinable
    static func hours(_ value: Int64) -> Self {
        let duration: Duration = .hours(value)
        return Self(duration)
    }

    @inlinable
    static func days(_ value: Int) -> Self {
        let duration: Duration = .days(value)
        return Self(duration)
    }

    @inlinable
    static func days(_ value: Int64) -> Self {
        let duration: Duration = .days(value)
        return Self(duration)
    }

    @inlinable
    static func weeks(_ value: Int) -> Self {
        let duration: Duration = .weeks(value)
        return Self(duration)
    }

    @inlinable
    static func weeks(_ value: Int64) -> Self {
        let duration: Duration = .weeks(value)
        return Self(duration)
    }
}

extension FixedOffset: TimeZoneProtocol {
    public var identifier: String {
        if duration == .zero { return "UTC" }

        let totalSeconds = Int(duration.seconds)
        let total = abs(totalSeconds)
        let hours = total / Seconds.perHour
        let minutes = (total % Seconds.perHour) / Seconds.perMinute
        let sign = duration.seconds < 0 ? "-" : "+"

        return "\(sign)\(hours.paddedTwoDigit):\(minutes.paddedTwoDigit)"
    }

    @inlinable
    public func offset(for _: Instant) -> Duration {
        duration
    }

    @inlinable
    public func offset(for _: NaiveDateTime) -> LocalOffset {
        .unique(duration)
    }
}
