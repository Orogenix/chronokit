import ChronoCore
@testable import ChronoParser
import Testing

// MARK: - RFC 3339 Tests

struct DateTimeParserTests {
    @Test("DateTimeParserTests: RFC 3339 Fails when offset is missing", arguments: [
        "2025-12-29T15:30:45",
        "2025-12-29 15:30:45",
        "2025-02-10",
    ])
    func missingOffsetFails_rfc3339(input: String) {
        let dt = DateTime<FixedOffset>(rfc3339: input)
        #expect(dt == nil)
    }

    @Test("DateTimeParserTests: RFC 3339 Correctly captures local time and offset", arguments: [
        ("2025-12-29T10:00:00Z", 10, 0),
        ("2025-12-29T10:00:00+07:00", 10, 25200),
        ("2025-12-29T10:00:00-05:00", 10, -18000),
        ("2025-12-29T10:00:00+0530", 10, 19800) // India Standard Time
    ])
    func offsetCapture_rfc3339(input: String, hour: Int, offset: Int) throws {
        let dt = DateTime<FixedOffset>(rfc3339: input)
        #expect(dt != nil)
        #expect(dt?.hour == hour)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)) == .seconds(offset))
    }

    @Test("DateTimeParserTests: RFC 3339 Handles fractional seconds with offset", arguments: [
        ("2025-12-29T10:00:00.500Z", 500_000_000),
        ("2025-12-29T10:00:00.123456789+01:00", 123_456_789),
    ])
    func fractionsAndOffset_rfc3339(input: String, expectedNanos: Int) {
        let dt = DateTime<FixedOffset>(rfc3339: input)
        #expect(dt?.nanosecond == expectedNanos)
    }

    @Test("DateTimeParserTests: RFC 3339 Delegates calendar validation correctly", arguments: [
        "2025-02-30T10:00:00Z", // Invalid day
        "2025-04-31T10:00:00Z", // April has 30 days
        "2025-12-29T24:00:00Z", // 24:00 is usually invalid in strict parsers
    ])
    func calendarValidation_rfc3339(input: String) {
        let dt = DateTime<FixedOffset>(rfc3339: input)
        #expect(dt == nil)
    }

    @Test("DateTimeParserTests: RFC 3339 Supports comma separator with offset")
    func commaWithOffset_rfc3339() throws {
        let input = "2025-12-29T10:00:00,5+02:00"
        let dt = DateTime<FixedOffset>(rfc3339: input)

        #expect(dt != nil)
        #expect(dt?.nanosecond == 500_000_000)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)) == .hours(2))
    }

    @Test("DateTimeParserTests: RFC 3339 Supports compact offsets (no colons)", arguments: [
        ("2025-12-29T10:00:00+0700", 25200),
        ("2025-12-29T10:00:00-05", -18000),
    ])
    func compactOffsets_rfc3339(input: String, expectedSeconds: Int64) throws {
        let dt = DateTime<FixedOffset>(rfc3339: input)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)).seconds == expectedSeconds)
    }

    @Test("DateTimeParserTests: RFC 3339 Malformed fractional strings should fail", arguments: [
        "2025-12-29T10:00:00.Z", // Dot with no digits
        "2025-12-29T10:00:00,Z", // Comma with no digits
        "2025-12-29T10:00:00. 5Z", // Space between dot and digit
        "2025-12-29T10:00:00.abcZ", // Letters in fraction
    ])
    func malformedFractions_rfc3339(input: String) {
        #expect(DateTime<FixedOffset>(rfc3339: input) == nil)
    }

    @Test("DateTimeParserTests: RFC 3339 Boundary times", arguments: [
        ("2025-12-29T00:00:00Z", 0), // Midnight start
        ("2025-12-29T23:59:59Z", 23), // Just before next day
    ])
    func boundaryTimes_rfc3339(input: String, expectedHour: Int) {
        let dt = DateTime<FixedOffset>(rfc3339: input)
        #expect(dt?.hour == expectedHour)
    }

    @Test("DateTimeParserTests: RFC 3339 Extreme offsets")
    func extremeOffsets_rfc3339() throws {
        // Valid ISO, though unlikely in the real world
        let input = "2025-12-29T10:00:00+18:00"
        let dt = DateTime<FixedOffset>(rfc3339: input)
        #expect(dt != nil)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)) == .hours(18))
    }
}

// MARK: - RFC 5322 Tests

extension DateTimeParserTests {
    @Test("DateTimeParserTests: RFC 5322 Valid inputs", arguments: [
        // Full standard
        ("Mon, 13 Apr 2026 13:46:00 +0000", 13, 46, 0),
        // Optional seconds/weekday
        ("13 Apr 2026 13:46 +0000", 13, 46, 0),
        // Different offsets
        ("13 Apr 2026 20:46:00 +0700", 20, 46, 25200),
        ("13 Apr 2026 08:46:00 -0500", 8, 46, -18000),
        // Obsolete alpha zones (Permissive)
        ("13 Apr 2026 13:46:00 UT", 13, 46, 0),
        ("13 Apr 2026 13:46:00 GMT", 13, 46, 0),
    ])
    func valid_rfc5322(input: String, hour: Int, min: Int, offset: Int) throws {
        let dt = DateTime<FixedOffset>(rfc5322: input)
        #expect(dt != nil)
        #expect(dt?.hour == hour)
        #expect(dt?.minute == min)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)).seconds == Int64(offset))
    }

    @Test("DateTimeParserTests: RFC 5322 Permissive cases (Robutness)", arguments: [
        // Many systems emit RFC 5322 dates but include the colon in the offset
        ("Mon, 13 Apr 2026 13:46:00 +00:00", 13, 46, 0),
        // Short offset
        ("13 Apr 2026 13:46:00 +07", 13, 46, 25200),
    ])
    func permissive_rfc5322(input: String, hour _: Int, min _: Int, offset: Int) throws {
        let dt = DateTime<FixedOffset>(rfc5322: input)
        #expect(dt != nil)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)).seconds == Int64(offset))
    }

    @Test("DateTimeParserTests: RFC 5322 Failure cases", arguments: [
        "Mon 13 Apr 2026 13:46:00 +0000", // Missing comma
        "13 Apr 2026 13:46:00", // Missing offset
        "13 April 2026 13:46:00 +0000", // Full month name (invalid)
        "13 Apr 2026 13:46:00 UTC", // 'UTC' is not a valid 5322 alpha zone
        "13 Apr 2026 13:46:00 +07:", // Dangling colon
    ])
    func failures_rfc5322(input: String) {
        let dt = DateTime<FixedOffset>(rfc5322: input)
        #expect(dt == nil)
    }

    @Test("DateTimeParserTests: RFC 5322 Fractional support (Optional/Robust)", arguments: [
        // While not strictly RFC 5322, some systems (like Python) append fractions to these strings
        ("13 Apr 2026 13:46:00.500 +0000", 500_000_000)
    ])
    func fractions_rfc5322(input: String, expectedNanos: Int) {
        let dt = DateTime<FixedOffset>(rfc5322: input)
        #expect(dt?.nanosecond == expectedNanos)
    }
}

// MARK: - RFC 2822 Tests

extension DateTimeParserTests {
    @available(*, deprecated)
    @Test("DateTimeParserTests: RFC 2822 alias yields identical results to RFC 5322")
    func redirectedDeprecation_rfc2822() {
        let date = "Mon, 13 Apr 2026 13:46:00 +0000"
        let modern = DateTime(rfc5322: date)
        let deprecated = DateTime(rfc2822: date)
        #expect(deprecated != nil)
        #expect(deprecated == modern)
    }
}
