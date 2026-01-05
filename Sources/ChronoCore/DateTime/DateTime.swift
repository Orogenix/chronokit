public struct DateTime<TZ: TimeZoneProtocol>: Sendable {
    /// The exact moment in time, stored as UTC.
    public let instant: Instant

    /// The timezone associated with this instance.
    public let timezone: TZ

    @inlinable
    public init(instant: Instant, timezone: TZ) {
        self.instant = instant
        self.timezone = timezone
    }

    @inlinable
    public init?(
        year: Int32,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        nanosecond: Int = 0,
        timezone: TZ
    ) {
        guard
            let naiveLocal = NaiveDateTime(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                nanosecond: nanosecond
            ),
            let utcInstant = naiveLocal.instant(in: timezone)
        else { return nil }

        self.init(instant: utcInstant, timezone: timezone)
    }
}

// MARK: - Core Accessors

public extension DateTime {
    /// Unix Timestamp (Seconds). Fast O(1).
    @inlinable
    var timestamp: Int64 {
        instant.timestamp
    }

    /// Unix Timestamp (Microseconds). Fast O(1).
    @inlinable
    var timestampMicroseconds: Int64 {
        instant.timestampMicroseconds
    }

    /// Unix Timestamp (Nanoseconds). Fast O(1).
    @inlinable
    var timestampNanoSeconds: Int64 {
        instant.timestampNanoseconds
    }

    @inlinable
    var timestampNanosecondsChecked: Int64? {
        instant.timestampNanosecondsChecked
    }
}

// MARK: - Equality

extension DateTime: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        // Comparison is always done on the absolute instant (UTC),
        // ignoring the timezone offset.
        lhs.instant == rhs.instant
    }
}

// MARK: - Hash

extension DateTime: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(instant)
    }
}

// MARK: - Comparability

extension DateTime: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        // Comparison is always done on the absolute instant (UTC),
        // ignoring the timezone offset.
        lhs.instant < rhs.instant
    }
}

// MARK: - Arithmetic

public extension DateTime {
    @inlinable
    func advanced(bySeconds seconds: Int64, nanoseconds: Int64 = 0) -> Self {
        Self(
            instant: instant.advanced(bySeconds: seconds, nanoseconds: nanoseconds),
            timezone: timezone
        )
    }

    @inlinable
    func advanced(by duration: Duration) -> Self {
        advanced(
            bySeconds: duration.seconds,
            nanoseconds: Int64(duration.nanoseconds)
        )
    }
}

// MARK: - Addition

public extension DateTime {
    @inlinable
    static func + (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(by: rhs)
    }

    @inlinable
    static func + (lhs: Duration, rhs: Self) -> Self {
        rhs.advanced(by: lhs)
    }

    @inlinable
    static func += (lhs: inout Self, rhs: Duration) {
        lhs = lhs + rhs
    }
}

// MARK: - Substraction

public extension DateTime {
    @inlinable
    static func - (lhs: DateTime<TZ>, rhs: DateTime<some TimeZoneProtocol>) -> Duration {
        let instant = lhs.instant - rhs.instant
        return Duration(seconds: instant.seconds, nanoseconds: Int64(instant.nanoseconds))
    }

    @inlinable
    static func - (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(
            bySeconds: -rhs.seconds,
            nanoseconds: -Int64(rhs.nanoseconds)
        )
    }

    @inlinable
    static func -= (lhs: inout Self, rhs: Duration) {
        lhs = lhs - rhs
    }
}

// MARK: - Naive Conversion

extension DateTime {
    /// The 'Wall Clock' view of the time.
    /// This applies the timezone offset to the stored UTC time.
    @inlinable
    public var naive: NaiveDateTime {
        instant.naiveDateTime(in: timezone)
    }

    @usableFromInline
    func withLocal(
        resolving policy: DSTResolutionPolicy = .preferEarlier,
        _ transform: (NaiveDateTime) -> NaiveDateTime?
    ) -> Self? {
        guard let newNaive = transform(naive),
              let newInstant = newNaive.instant(
                  in: timezone,
                  resolving: policy
              )
        else { return nil }

        return Self(instant: newInstant, timezone: timezone)
    }
}
