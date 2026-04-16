import ChronoCore
@testable import ChronoFormatter
import Testing

struct DateTimeFormatterTests {
    @Test("DateTimeFormatterTests: UTC DateTime")
    func defaultUTC_rfc3339() {
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 0) // 2026-04-16T12:00:00Z
        let dt = DateTime(instant: instant, timezone: FixedOffset.utc)

        #expect(dt.rfc3339() == "2026-04-16T12:00:00Z")
        #expect(dt.description == "2026-04-16T12:00:00Z")
        #expect("Today is \(dt)" == "Today is 2026-04-16T12:00:00Z")
    }

    @Test("DateTimeFormatterTests: Positive Offset (Jakarta)")
    func positiveOffset_rfc3339() {
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 0)
        // UTC: 12:00:00 -> +07:00: 19:00:00
        let jkt = FixedOffset(seconds: 25200)
        let dt = DateTime(instant: instant, timezone: jkt)

        #expect(dt.rfc3339() == "2026-04-16T19:00:00+07:00")
    }

    @Test("DateTimeFormatterTests: Negative Offset with Fractions")
    func negativeOffsetWithFractions_rfc3339() {
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 500_000_000)
        // UTC: 12:00:00.5 -> -05:00: 07:00:00.5
        let nyc = FixedOffset(seconds: -18000)
        let dt = DateTime(instant: instant, timezone: nyc)

        #expect(dt.rfc3339(digits: 3) == "2026-04-16T07:00:00.500-05:00")
    }

    @Test("DateTimeFormatterTests: System TimeZone Roundtrip")
    func systemTimeZone_rfc3339() {
        let dt: DateTime = .now() // Uses SystemTimeZone
        let result = dt.rfc3339()

        // Ensure it contains a 'T' and either 'Z' or a sign (+/-)
        #expect(result.contains("T"))
        #expect(result.hasSuffix("Z") || result.contains("+") || result.contains("-"))
    }

    @Test("DateTimeFormatterTests: Fixed Fraction Width")
    func fixedFractionWidth_rfc3339() {
        let instant = Instant(seconds: 100, nanoseconds: 12345)
        let dt = DateTime(instant: instant, timezone: FixedOffset.utc)

        // Should pad nanoseconds correctly inside the DateTime context
        #expect(dt.rfc3339(digits: 9) == "1970-01-01T00:01:40.000012345Z")
    }

    @Test("DateTimeFormatterTests: Generic TimeZone Handling")
    func genericTimeZone_rfc3339() {
        let dt = DateTime(instant: .now(), timezone: MockZeroZone())
        #expect(dt.rfc3339().hasSuffix("Z"))
    }

    // MARK: Helpers

    struct MockZeroZone: TimeZoneProtocol {
        let identifier: String = "mock"

        func offset(for _: Instant) -> Duration {
            return .seconds(0)
        }

        func offset(for _: NaiveDateTime) -> LocalOffset {
            return .unique(Duration.seconds(0))
        }
    }
}
