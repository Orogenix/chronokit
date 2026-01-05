import ChronoCore
@testable import ChronoParse
import Testing

@Suite("Naive Date Time Parse Tests")
struct NaiveDateTimeParseTests {
    typealias Strategy = ChronoParser.Strategy

    @Test("NaiveDateTimeParseTests: Correctly parses valid ISO 8601 strings", arguments: [
        // (Input, Expected Year, Month, Day, Hour, Min, Sec)
        ("2025-12-29T15:30:45", Strategy.compact, 2025, 12, 29, 15, 30, 45),
        ("2025-12-29 15:30:45", Strategy.expanded, 2025, 12, 29, 15, 30, 45), // Expanded format
        ("1970-01-01T00:00:00", Strategy.compact, 1970, 1, 1, 0, 0, 0),
    ])
    // swiftlint:disable:next function_parameter_count
    func standardParsing(
        input: String,
        strategy: Strategy,
        year: Int32,
        month: Int,
        day: Int,
        hour: Int,
        min: Int,
        sec: Int
    ) {
        let ndt = NaiveDateTime(input, with: ChronoParser(strategy: strategy))

        #expect(ndt != nil)
        #expect(ndt?.year == year)
        #expect(ndt?.month == month)
        #expect(ndt?.day == day)
        #expect(ndt?.hour == hour)
        #expect(ndt?.minute == min)
        #expect(ndt?.second == sec)
    }

    @Test("NaiveDateTimeParseTests: NaiveDateTime ignores offsets (Permissive)", arguments: [
        "2025-12-29T10:00:00Z",
        "2025-12-29T10:00:00+07:00",
        "2025-12-29T10:00:00-05:00",
    ])
    func ignoresOffsets(input: String) {
        // All should parse to the same LOCAL time
        let ndt = NaiveDateTime(input)

        #expect(ndt != nil)
        #expect(ndt!.hour == 10)
    }

    @Test("NaiveDateTimeParseTests: Handles fractional seconds accurately", arguments: [
        ("2025-12-29T10:00:00.5", 500_000_000),
        ("2025-12-29T10:00:00.123456789", 123_456_789),
        ("2025-12-29T10:00:00,500", 500_000_000) // Comma separator
    ])
    func fractions(input: String, expectedNanos: Int) {
        let ndt = NaiveDateTime(input)
        #expect(ndt!.nanosecond == expectedNanos)
    }

    @Test("NaiveDateTimeParseTests: Fails on invalid calendar dates (Logical Validation)", arguments: [
        "2025-02-29T10:00:00", // Not a leap year
        "2025-13-01T10:00:00", // Month 13
        "2025-12-32T10:00:00", // Day 32
        "2025-12-29T25:00:00" // Hour 25
    ])
    func invalidDates(input: String) {
        // parser.parse might succeed, but NaiveDateTime.init? should return nil
        let ndt = NaiveDateTime(input)
        #expect(ndt == nil)
    }

    @Test("NaiveDateTimeParseTests: Fails on garbage strings", arguments: [
        "Not a date",
        "2025-12",
        "T10:00:00"
    ])
    func garbage(input: String) {
        #expect(NaiveDateTime(input) == nil)
    }
}
