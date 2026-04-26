import ChronoCore

public extension NaiveTime {
    static func now(in timezone: some TimeZoneProtocol) -> Self {
        NaiveDateTime.now(in: timezone).time
    }

    static func now() -> Self {
        now(in: SystemTimeZone())
    }
}
