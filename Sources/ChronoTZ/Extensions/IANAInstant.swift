import ChronoCore
import ChronoMath

public extension Instant {
    @inlinable
    func plainDateTime(
        in name: String,
        provider: (any TimeZoneProvider)? = nil
    ) throws -> PlainDateTime {
        let tzProvider = provider ?? IANAProvider.shared
        let timezone = try tzProvider.getTimeZone(named: name)
        return plainDateTime(in: timezone)
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
