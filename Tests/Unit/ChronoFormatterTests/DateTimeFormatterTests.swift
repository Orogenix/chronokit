import ChronoCore
@testable import ChronoFormatter
import ChronoSystem
import Testing

// MARK: - RFC 3339 Tests

struct DateTimeFormatterTests {
    @Test("DateTimeFormatterTests: UTC RFC 3339 DateTime")
    func defaultUTC_rfc3339() {
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 0) // 2026-04-16T12:00:00Z
        let dt = DateTime(instant: instant, timezone: FixedOffset.utc)
        #expect(dt.rfc3339() == "2026-04-16T12:00:00Z")
        #expect(dt.description == "2026-04-16T12:00:00Z")
        #expect("Today is \(dt)" == "Today is 2026-04-16T12:00:00Z")
    }

    @Test("DateTimeFormatterTests: Positive Offset RFC 3339 (Jakarta)")
    func positiveOffset_rfc3339() {
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 0)
        // UTC: 12:00:00 -> +07:00: 19:00:00
        let jkt = FixedOffset(seconds: 25200)
        let dt = DateTime(instant: instant, timezone: jkt)

        #expect(dt.rfc3339() == "2026-04-16T19:00:00+07:00")
    }

    @Test("DateTimeFormatterTests: Negative Offset RFC 3339 with Fractions")
    func negativeOffsetWithFractions_rfc3339() {
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 500_000_000)
        // UTC: 12:00:00.5 -> -05:00: 07:00:00.5
        let nyc = FixedOffset(seconds: -18000)
        let dt = DateTime(instant: instant, timezone: nyc)

        #expect(dt.rfc3339(digits: 3) == "2026-04-16T07:00:00.500-05:00")
    }

    @Test("DateTimeFormatterTests: RFC 3339 System TimeZone Roundtrip")
    func systemTimeZone_rfc3339() {
        let dt: DateTime = .now() // Uses SystemTimeZone
        let result = dt.rfc3339()

        // Ensure it contains a 'T' and either 'Z' or a sign (+/-)
        #expect(result.contains("T"))
        #expect(result.hasSuffix("Z") || result.contains("+") || result.contains("-"))
    }

    @Test("DateTimeFormatterTests: RFC 3339 Fixed Fraction Width")
    func fixedFractionWidth_rfc3339() {
        let instant = Instant(seconds: 100, nanoseconds: 12345)
        let dt = DateTime(instant: instant, timezone: FixedOffset.utc)

        // Should pad nanoseconds correctly inside the DateTime context
        #expect(dt.rfc3339(digits: 9) == "1970-01-01T00:01:40.000012345Z")
    }

    @Test("DateTimeFormatterTests: RFC 3339 Generic TimeZone Handling")
    func genericTimeZone_rfc3339() {
        let dt = DateTime(instant: .now(), timezone: MockZeroZone())
        #expect(dt.rfc3339().hasSuffix("Z"))
    }

    @Test("DateTimeFormatterTests: Half-hour RFC 3339 Offset (India)")
    func halfHourOffset_rfc3339() {
        let instant = Instant(seconds: 1_773_748_800, nanoseconds: 0) // 12:00:00 UTC
        let ist = FixedOffset(seconds: 19800) // +05:30
        let dt = DateTime(instant: instant, timezone: ist)
        #expect(dt.rfc3339() == "2026-03-17T17:30:00+05:30")
    }
}

// MARK: - RFC 5322 Tests

extension DateTimeFormatterTests {
    @Test("DateTimeFormatterTests: RFC 5322 standard formatting (Jakarta)")
    func positiveOffset_rfc5322() {
        // UTC: 12:00:00 -> 2026-03-17 (Tuesday)
        // Jakarta (+07:00): 19:00:00 -> Still 2026-03-17 (Tuesday)
        let instant = Instant(seconds: 1_773_748_800, nanoseconds: 0)
        let jkt = FixedOffset(seconds: 25200)
        let dt = DateTime(instant: instant, timezone: jkt)

        #expect(dt.rfc5322() == "Tue, 17 Mar 2026 19:00:00 +0700")
    }

    @Test("DateTimeFormatterTests: RFC 5322 Cross-Day Offset (NYC)")
    func negativeOffsetCrossDay_rfc5322() {
        // UTC: 2026-03-17 02:00:00 (Tuesday)
        // NYC (-05:00): 2026-03-16 21:00:00 (Monday)
        let instant = Instant(seconds: 1_773_712_800, nanoseconds: 0)
        let nyc = FixedOffset(seconds: -18000)
        let dt = DateTime(instant: instant, timezone: nyc)

        #expect(dt.rfc5322() == "Mon, 16 Mar 2026 21:00:00 -0500")
    }

    @Test("DateTimeFormatterTests: RFC 5322 UTC handling")
    func utc_rfc5322() {
        let instant = Instant(seconds: 0, nanoseconds: 0)
        let dt = DateTime(instant: instant, timezone: FixedOffset.utc)

        // RFC 5322 prefers numeric offset +0000 for UTC
        #expect(dt.rfc5322() == "Thu, 01 Jan 1970 00:00:00 +0000")
    }

    @Test("DateTimeFormatterTests: Half-hour RFC 5322 Offset (India)")
    func halfHourOffset_rfc5322() {
        let instant = Instant(seconds: 1_773_748_800, nanoseconds: 0) // 12:00:00 UTC
        let ist = FixedOffset(seconds: 19800) // +05:30
        let dt = DateTime(instant: instant, timezone: ist)
        #expect(dt.rfc5322() == "Tue, 17 Mar 2026 17:30:00 +0530")
    }

    @Test("DateTimeFormatterTests: RFC 5322 Boundary Capacity Check")
    func capacityCheck() throws {
        // "Tue, 17 Mar 2026 19:00:00 +0700" is 31 chars.
        // Your capacity is 48, which is plenty for RFC 5322.
        let instant = Instant(seconds: 1_773_748_800, nanoseconds: 999_999_999)
        let dt = DateTime(instant: instant, timezone: FixedOffset(seconds: 25200))

        let result = try #require(dt.rfc5322())
        #expect(result.count <= 48)
    }
}

// MARK: - RFC 2822 Tests

extension DateTimeFormatterTests {
    @available(*, deprecated)
    @Test("DateTimeFormatterTests: RFC 2822 alias yields identical results to RFC 5322")
    func redirectedDeprecation_rfc2822() {
        let instant = Instant(seconds: 1_773_748_800, nanoseconds: 0)
        let jkt = FixedOffset(seconds: 25200)
        let dt = DateTime(instant: instant, timezone: jkt)
        let modern = dt.rfc5322()
        let deprecated = dt.rfc2822()
        #expect(deprecated != nil)
        #expect(deprecated == modern)
    }
}

// MARK: - Helpers

extension DateTimeFormatterTests {
    struct MockZeroZone: TimeZoneProtocol {
        let identifier: String = "mock"

        func offset(for _: Instant) -> Duration {
            return .seconds(0)
        }

        func offset(for _: PlainDateTime) -> PlainOffset {
            return .unique(.standard(.seconds(0)))
        }
    }
}
