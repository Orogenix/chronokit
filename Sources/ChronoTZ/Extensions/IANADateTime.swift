import ChronoCore
import ChronoSystem

public extension DateTime where TZ == TimeZoneInfo {
    @inlinable
    init(
        instant: Instant,
        timezone name: String,
        provider: (any TimeZoneProvider)? = nil
    ) throws {
        let tzProvider = provider ?? IANAProvider.shared
        let timezone = try tzProvider.getTimeZone(named: name)
        self.init(instant: instant, timezone: timezone)
    }

    @inlinable
    static func now(
        in name: String,
        provider: (any TimeZoneProvider)? = nil
    ) throws -> Self {
        try self.init(
            instant: .now(),
            timezone: name,
            provider: provider ?? IANAProvider.shared
        )
    }
}
