import ChronoCore
@testable import ChronoFormatter
import Testing

// MARK: - RFC 3339 Tests

struct NaiveDateTimeFormatterTests {
    let dt = NaiveDateTime(
        year: 2026, month: 12, day: 29,
        hour: 15, minute: 30, second: 0,
        nanosecond: 500_000_000
    )

    @Test("NaiveDateTimeFormatterTests: Default string RFC 3339 formatting")
    func defaultCombinedFormatting_rfc3339() throws {
        let datetime = try #require(dt, "Sample naive date time should valid")
        #expect(datetime.rfc3339() == "2026-12-29T15:30:00")
        #expect(datetime.description == "2026-12-29T15:30:00")
        #expect("Today is \(datetime)" == "Today is 2026-12-29T15:30:00")
    }

    @Test("NaiveDateTimeFormatterTests: RFC 3339 combined string with custom precision", arguments: [
        (3, "2026-12-29T15:30:00.500"),
        (0, "2026-12-29T15:30:00"),
    ])
    func combinedPrecision_rfc3339(digits: Int, expected: String) throws {
        let datetime = try #require(dt, "Sampe naive date time should valid")
        #expect(datetime.rfc3339(digits: digits) == expected)
    }

    @Test("NaiveDateTimeFormatterTests: RFC 3339 Naive with Fixed Offset")
    func withOffset_rfc3339() throws {
        let dt = NaiveDateTime(year: 2026, month: 4, day: 16, hour: 13, minute: 0, second: 0)
        let naive = try #require(dt)
        let offset = FixedOffset(seconds: 25200) // +07:00
        let result = naive.rfc3339(digits: 0, offset: offset)
        #expect(result == "2026-04-16T13:00:00+07:00")
    }

    @Test("NaiveDateTimeFormatterTests: RFC 3339 Naive with UTC Offset (Zulu)")
    func withUTCOffset_rfc3339() throws {
        let dt = NaiveDateTime(year: 2026, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        let naive = try #require(dt)
        let result = naive.rfc3339(digits: 0, offset: .utc)
        #expect(result == "2026-01-01T00:00:00Z", "Should print zulu offset")
    }

    @Test("NaiveDateTimeFormatterTests: RFC 3339 Fractions and Offsets Combined")
    func fractionsAndOffsets_rfc3339() throws {
        let dt = NaiveDateTime(year: 2026, month: 4, day: 16, hour: 13, minute: 0, second: 0, nanosecond: 123_456_789)
        let naive = try #require(dt)
        let offset = FixedOffset(seconds: -18000) // -05:00
        #expect(naive.rfc3339(digits: 3, offset: offset) == "2026-04-16T13:00:00.123-05:00")
        #expect(naive.rfc3339(digits: 9, offset: offset) == "2026-04-16T13:00:00.123456789-05:00")
    }

    @Test("NaiveDateTimeFormatterTests: RFC 3339 Max Digits Padding")
    func fractionPadding_rfc3339() throws {
        let dt = NaiveDateTime(year: 2026, month: 4, day: 16, hour: 12, minute: 0, second: 0, nanosecond: 0)
        let naive = try #require(dt)
        #expect(naive.rfc3339(digits: 3) == "2026-04-16T12:00:00.000", "Should print .000 even if nanos is 0")
    }

    @Test("NaiveDateTimeFormatterTests: Leap Year RFC 3339")
    func leapYear_rfc3339() throws {
        let leap = try #require(NaiveDateTime(
            year: 2024,
            month: 2,
            day: 29,
            hour: 23,
            minute: 59,
            second: 59
        ))
        #expect(leap.rfc3339() == "2024-02-29T23:59:59")
    }

    @Test("NaiveDateTimeFormatterTests: RFC 3339 Formatting at Year Boundaries")
    func yearBoundaries_rfc3339() throws {
        let yearStart = try #require(NaiveDateTime(
            year: 2026,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0
        ))
        let yearEnd = try #require(NaiveDateTime(
            year: 2025,
            month: 12,
            day: 31,
            hour: 23,
            minute: 59,
            second: 59
        ))

        #expect(yearStart.rfc3339() == "2026-01-01T00:00:00")
        #expect(yearEnd.rfc3339() == "2025-12-31T23:59:59")
    }
}

// MARK: - RFC 5322 Tests

extension NaiveDateTimeFormatterTests {
    @Test("NaiveDateTimeFormatterTests: RFC 5322 standard formatting", arguments: [
        (2026, 12, 29, 15, 30, 0, "Tue, 29 Dec 2026 15:30:00"),
    ])
    // swiftlint:disable:next function_parameter_count
    func formatting_rfc5322(
        year: Int32,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        expected: String
    ) throws {
        let datetime = try #require(NaiveDateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        ))
        #expect(datetime.rfc5322() == expected)
    }

    @Test("NaiveDateTimeFormatterTests: RFC 5322 with Offset", arguments: [
        (25200, "Tue, 29 Dec 2026 15:30:00 +0700"), // +07:00
        (-18000, "Tue, 29 Dec 2026 15:30:00 -0500"), // -05:00
        (0, "Tue, 29 Dec 2026 15:30:00 +0000"), // RFC 5322 uses +0000, not Z
    ])
    func withOffset_rfc5322(seconds: Int, expected: String) throws {
        let datetime = try #require(dt)
        let offset = FixedOffset(seconds: seconds)
        #expect(datetime.rfc5322(offset: offset) == expected)
    }

    @Test("NaiveDateTimeFormatterTests: Handling nil month in RFC 5322")
    func invalidMonth_rfc5322() {
        let rawDT = NaiveDateTime(
            year: 2026,
            month: 13,
            day: 1,
            hour: 12,
            minute: 0,
            second: 0
        )
        #expect(rawDT?.rfc5322() == nil)
    }
}

// MARK: - RFC 2822 Tests

extension NaiveDateTimeFormatterTests {
    @available(*, deprecated)
    @Test("NaiveDateTimeFormatterTests: RFC 2822 alias yields identical results to RFC 5322")
    func redirectedDeprecation_rfc2822() throws {
        let datetime = try #require(NaiveDateTime(
            year: 2026,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0
        ))
        let modern = datetime.rfc5322()
        let deprecated = datetime.rfc2822()
        #expect(deprecated != nil)
        #expect(deprecated == modern)
    }
}
