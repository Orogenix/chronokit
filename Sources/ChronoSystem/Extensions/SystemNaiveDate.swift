import ChronoCore

public extension NaiveDate {
    static func now(in timezone: some TimeZoneProtocol) -> Self {
        NaiveDateTime.now(in: timezone).date
    }

    static func now() -> Self {
        now(in: SystemTimeZone())
    }
}
