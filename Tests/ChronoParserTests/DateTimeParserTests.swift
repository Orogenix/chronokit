import ChronoCore
@testable import ChronoParser
import Testing

struct DateTimeParserTests {
    @Test("DateTimeParserTests: Fails when offset is missing", arguments: [
        "2025-12-29T15:30:45",
        "2025-12-29 15:30:45",
        "2025-02-10",
    ])
    func missingOffsetFails_rfc3339(input: String) {
        let dt = DateTime<FixedOffset>(input, as: .rfc3339)
        #expect(dt == nil)
    }

    @Test("DateTimeParserTests: Correctly captures local time and offset", arguments: [
        ("2025-12-29T10:00:00Z", 10, 0),
        ("2025-12-29T10:00:00+07:00", 10, 25200),
        ("2025-12-29T10:00:00-05:00", 10, -18000),
        ("2025-12-29T10:00:00+0530", 10, 19800) // India Standard Time
    ])
    func offsetCapture_rfc3339(input: String, hour: Int, offset: Int) throws {
        let dt = DateTime<FixedOffset>(input, as: .rfc3339)

        #expect(dt != nil)
        #expect(dt?.hour == hour)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)) == .seconds(offset))
    }

    @Test("DateTimeParserTests: Handles fractional seconds with offset", arguments: [
        ("2025-12-29T10:00:00.500Z", 500_000_000),
        ("2025-12-29T10:00:00.123456789+01:00", 123_456_789),
    ])
    func fractionsAndOffset_rfc3339(input: String, expectedNanos: Int) {
        let dt = DateTime<FixedOffset>(input, as: .rfc3339)
        #expect(dt?.nanosecond == expectedNanos)
    }

    @Test("DateTimeParserTests: Delegates calendar validation correctly", arguments: [
        "2025-02-30T10:00:00Z", // Invalid day
        "2025-04-31T10:00:00Z", // April has 30 days
        "2025-12-29T24:00:00Z", // 24:00 is usually invalid in strict parsers
    ])
    func calendarValidation_rfc3339(input: String) {
        let dt = DateTime<FixedOffset>(input, as: .rfc3339)
        #expect(dt == nil)
    }

    @Test("DateTimeParserTests: Supports comma separator with offset")
    func commaWithOffset_rfc3339() throws {
        let input = "2025-12-29T10:00:00,5+02:00"
        let dt = DateTime<FixedOffset>(input, as: .rfc3339)

        #expect(dt != nil)
        #expect(dt?.nanosecond == 500_000_000)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)) == .hours(2))
    }

    @Test("DateTimeParserTests: Supports compact offsets (no colons)", arguments: [
        ("2025-12-29T10:00:00+0700", 25200),
        ("2025-12-29T10:00:00-05", -18000),
    ])
    func compactOffsets_rfc3339(input: String, expectedSeconds: Int64) throws {
        let dt = DateTime<FixedOffset>(input, as: .rfc3339)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)).seconds == expectedSeconds)
    }

    @Test("DateTimeParserTests: Malformed fractional strings should fail", arguments: [
        "2025-12-29T10:00:00.Z", // Dot with no digits
        "2025-12-29T10:00:00,Z", // Comma with no digits
        "2025-12-29T10:00:00. 5Z", // Space between dot and digit
        "2025-12-29T10:00:00.abcZ", // Letters in fraction
    ])
    func malformedFractions_rfc3339(input: String) {
        #expect(DateTime<FixedOffset>(input, as: .rfc3339) == nil)
    }

    @Test("DateTimeParserTests: Boundary times", arguments: [
        ("2025-12-29T00:00:00Z", 0), // Midnight start
        ("2025-12-29T23:59:59Z", 23), // Just before next day
    ])
    func boundaryTimes_rfc3339(input: String, expectedHour: Int) {
        let dt = DateTime<FixedOffset>(input, as: .rfc3339)
        #expect(dt?.hour == expectedHour)
    }

    @Test("DateTimeParserTests: Extreme offsets")
    func extremeOffsets_rfc3339() throws {
        // Valid ISO, though unlikely in the real world
        let input = "2025-12-29T10:00:00+18:00"
        let dt = DateTime<FixedOffset>(input, as: .rfc3339)
        #expect(dt != nil)
        #expect(try dt?.timezone.offset(for: #require(dt?.instant)) == .hours(18))
    }
}
