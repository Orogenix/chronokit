import ChronoCore
import ChronoMath

public extension PlainDateTime {
    @inlinable
    func instant(
        in name: String,
        resolving policy: DSTResolutionPolicy = .preferEarlier,
        provider: (any TimeZoneProvider)? = nil
    ) throws -> Instant {
        let tzProvider = provider ?? IANAProvider.shared
        let timezone = try tzProvider.getTimeZone(named: name)

        guard let instant = instant(in: timezone, resolving: policy) else {
            throw TimeZoneError.zoneNotFound(name)
        }
        return instant
    }

    @inlinable
    func dateTime(
        timezone name: String,
        provider: (any TimeZoneProvider)? = nil
    ) throws -> DateTime<TimeZoneInfo> {
        let tzProvider = provider ?? IANAProvider.shared
        let timezone = try tzProvider.getTimeZone(named: name)
        guard let dt = dateTime(timezone: timezone) else {
            throw TimeZoneError.zoneNotFound(name)
        }
        return dt
    }
}
