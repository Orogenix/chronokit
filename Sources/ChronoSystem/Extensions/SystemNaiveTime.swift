import ChronoCore

public extension PlainTime {
    static func now(in timezone: some TimeZoneProtocol) -> Self {
        PlainDateTime.now(in: timezone).time
    }

    static func now() -> Self {
        now(in: SystemTimeZone())
    }
}
