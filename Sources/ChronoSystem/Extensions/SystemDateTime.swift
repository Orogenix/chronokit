import ChronoCore

public extension DateTime where TZ == SystemTimeZone {
    @inlinable
    static func now() -> Self {
        Self(instant: .now(), timezone: SystemTimeZone())
    }

    @inlinable
    func fixedOffset() -> DateTime<FixedOffset> {
        let currentOffset = timezone.offset(for: instant)
        return DateTime<FixedOffset>(
            instant: instant,
            timezone: FixedOffset(currentOffset)
        )
    }
}

public extension DateTime where TZ == FixedOffset {
    @inlinable
    static func now(in timezone: FixedOffset = .utc) -> Self {
        Self(instant: .now(), timezone: timezone)
    }

    @inlinable
    static var nowUTC: Self {
        now(in: .utc)
    }
}

public extension DateTime {
    @inlinable
    static func now(in timezone: TZ) -> Self {
        Self(instant: .now(), timezone: timezone)
    }
}
