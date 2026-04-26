import ChronoCore

public extension NaiveDateTime {
    static func now(in timezone: some TimeZoneProtocol) -> Self {
        Instant.now().naiveDateTime(in: timezone)
    }

    static func now() -> Self {
        now(in: SystemTimeZone())
    }
}
