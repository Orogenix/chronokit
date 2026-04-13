import ChronoCore
@testable import ChronoParser
import Testing

struct NaiveDateTimeParserTests {
    @Test("NaiveDateTimeParserTests: Correctly parses valid ISO 8601 strings", arguments: [
        // (Input, Expected Year, Month, Day, Hour, Min, Sec)
        ("2025-12-29T15:30:45", 2025, 12, 29, 15, 30, 45),
        ("1970-01-01T00:00:00", 1970, 1, 1, 0, 0, 0),
    ])
    // swiftlint:disable:next function_parameter_count
    func standardParsing_rfc3339(
        input: String,
        year: Int32,
        month: Int,
        day: Int,
        hour: Int,
        min: Int,
        sec: Int
    ) {
        let ndt = NaiveDateTime(input, as: .rfc3339)
        #expect(ndt != nil)
        #expect(ndt?.year == year)
        #expect(ndt?.month == month)
        #expect(ndt?.day == day)
        #expect(ndt?.hour == hour)
        #expect(ndt?.minute == min)
        #expect(ndt?.second == sec)
    }

    @Test("NaiveDateTimeParserTests: NaiveDateTime ignores offsets (Permissive)", arguments: [
        "2025-12-29T10:00:00Z",
        "2025-12-29T10:00:00+07:00",
        "2025-12-29T10:00:00-05:00",
    ])
    func ignoresOffsets_rfc3339(input: String) {
        // All should parse to the same LOCAL time
        let ndt = NaiveDateTime(input, as: .rfc3339)
        #expect(ndt != nil)
        #expect(ndt?.hour == 10)
    }

    @Test("NaiveDateTimeParserTests: Handles fractional seconds accurately", arguments: [
        ("2025-12-29T10:00:00.5", 500_000_000),
        ("2025-12-29T10:00:00.123456789", 123_456_789),
        ("2025-12-29T10:00:00,500", 500_000_000) // Comma separator
    ])
    func fractions_rfc3339(input: String, expectedNanos: Int) {
        let ndt = NaiveDateTime(input, as: .rfc3339)
        #expect(ndt?.nanosecond == expectedNanos)
    }

    @Test("NaiveDateTimeParserTests: Fails on invalid calendar dates (Logical Validation)", arguments: [
        "2025-02-29T10:00:00", // Not a leap year
        "2025-13-01T10:00:00", // Month 13
        "2025-12-32T10:00:00", // Day 32
        "2025-12-29T25:00:00" // Hour 25
    ])
    func invalidDates_rfc3339(input: String) {
        // parser.parse might succeed, but NaiveDateTime.init? should return nil
        let ndt = NaiveDateTime(input, as: .rfc3339)
        #expect(ndt == nil)
    }

    @Test("NaiveDateTimeParserTests: Fails on garbage strings", arguments: [
        "Not a date",
        "2025-12",
        "T10:00:00"
    ])
    func garbage_rfc3339(input: String) {
        #expect(NaiveDateTime(input, as: .rfc3339) == nil)
    }
}
