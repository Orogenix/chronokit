import ChronoCore

public extension PlainDate {
    static func now(in timezone: some TimeZoneProtocol) -> Self {
        PlainDateTime.now(in: timezone).date
    }

    static func now() -> Self {
        now(in: SystemTimeZone())
    }
}
