import ChronoCore
import ChronoMath

public extension Instant {
    @inlinable
    func naiveDateTime(
        in name: String,
        provider: (any TimeZoneProvider)? = nil
    ) throws -> NaiveDateTime {
        let tzProvider = provider ?? IANAProvider.shared
        let timezone = try tzProvider.getTimeZone(named: name)
        return naiveDateTime(in: timezone)
    }

    @inlinable
    func dateTime(
        in name: String,
        provider: (any TimeZoneProvider)? = nil
    ) throws -> DateTime<TimeZoneInfo> {
        let tzProvider = provider ?? IANAProvider.shared
        let timezone = try tzProvider.getTimeZone(named: name)
        return dateTime(in: timezone)
    }
}
