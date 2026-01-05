import ChronoCore
@testable import ChronoParse
import Testing

@Suite("Date Time Parse Tests")
struct DateTimeParseTests {
    @Test("DateTimeParseTests: Fails when offset is missing", arguments: [
        "2025-12-29T15:30:45",
        "2025-12-29 15:30:45",
        "2025-02-10",
    ])
    func missingOffsetFails(input: String) {
        let dt = DateTime<FixedOffset>(input)
        #expect(dt == nil)
    }

    @Test("DateTimeParseTests: Correctly captures local time and offset", arguments: [
        ("2025-12-29T10:00:00Z", 10, 0),
        ("2025-12-29T10:00:00+07:00", 10, 25200),
        ("2025-12-29T10:00:00-05:00", 10, -18000),
        ("2025-12-29T10:00:00+0530", 10, 19800) // India Standard Time
    ])
    func offsetCapture(input: String, hour: Int, offset: Int) {
        let dt = DateTime<FixedOffset>(input)

        #expect(dt != nil)
        #expect(dt!.hour == hour)
        #expect(dt!.timezone.offset(for: dt!.instant) == .seconds(offset))
    }

    @Test("DateTimeParseTests: Handles fractional seconds with offset", arguments: [
        ("2025-12-29T10:00:00.500Z", 500_000_000),
        ("2025-12-29T10:00:00.123456789+01:00", 123_456_789)
    ])
    func fractionsAndOffset(input: String, expectedNanos: Int) {
        let dt = DateTime<FixedOffset>(input)
        #expect(dt!.nanosecond == expectedNanos)
    }

    @Test("DateTimeParseTests: Delegates calendar validation correctly", arguments: [
        "2025-02-30T10:00:00Z", // Invalid day
        "2025-04-31T10:00:00Z", // April has 30 days
        "2025-12-29T24:00:00Z" // 24:00 is usually invalid in strict parsers
    ])
    func calendarValidation(input: String) {
        let dt = DateTime<FixedOffset>(input)
        #expect(dt == nil)
    }

    @Test("DateTimeParseTests: Supports comma separator with offset")
    func commaWithOffset() {
        let input = "2025-12-29T10:00:00,5+02:00"
        let dt = DateTime<FixedOffset>(input)

        #expect(dt != nil)
        #expect(dt!.nanosecond == 500_000_000)
        #expect(dt!.timezone.offset(for: dt!.instant) == .hours(2))
    }

    @Test("DateTimeParseTests: Supports compact offsets (no colons)", arguments: [
        ("2025-12-29T10:00:00+0700", 25200),
        ("2025-12-29T10:00:00-05", -18000)
    ])
    func compactOffsets(input: String, expectedSeconds: Int64) {
        let dt = DateTime<FixedOffset>(input)
        #expect(dt?.timezone.offset(for: dt!.instant).seconds == expectedSeconds)
    }

    @Test("DateTimeParseTests: Malformed fractional strings should fail", arguments: [
        "2025-12-29T10:00:00.Z", // Dot with no digits
        "2025-12-29T10:00:00,Z", // Comma with no digits
        "2025-12-29T10:00:00. 5Z", // Space between dot and digit
        "2025-12-29T10:00:00.abcZ" // Letters in fraction
    ])
    func malformedFractions(input: String) {
        #expect(DateTime<FixedOffset>(input) == nil)
    }

    @Test("DateTimeParseTests: Boundary times", arguments: [
        ("2025-12-29T00:00:00Z", 0), // Midnight start
        ("2025-12-29T23:59:59Z", 23) // Just before next day
    ])
    func boundaryTimes(input: String, expectedHour: Int) {
        let dt = DateTime<FixedOffset>(input)
        #expect(dt?.hour == expectedHour)
    }

    @Test("DateTimeParseTests: Extreme offsets")
    func extremeOffsets() {
        // Valid ISO, though unlikely in the real world
        let input = "2025-12-29T10:00:00+18:00"
        let dt = DateTime<FixedOffset>(input)
        #expect(dt != nil)
        #expect(dt?.timezone.offset(for: dt!.instant) == .hours(18))
    }
}
