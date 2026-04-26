import ChronoCore

public extension PlainDateTime {
    static func now(in timezone: some TimeZoneProtocol) -> Self {
        Instant.now().plainDateTime(in: timezone)
    }

    static func now() -> Self {
        now(in: SystemTimeZone())
    }
}
