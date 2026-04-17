import ChronoCore
@testable import ChronoParser
import Testing

// MARK: - RFC3339 Tests

struct NaiveDateTimeParserTests {
    @Test("NaiveDateTimeParserTests: Correctly parses valid RFC3339 strings", arguments: [
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
        let ndt = NaiveDateTime(rfc3339: input)
        #expect(ndt != nil)
        #expect(ndt?.year == year)
        #expect(ndt?.month == month)
        #expect(ndt?.day == day)
        #expect(ndt?.hour == hour)
        #expect(ndt?.minute == min)
        #expect(ndt?.second == sec)
    }

    @Test("NaiveDateTimeParserTests: RFC3339 ignores offsets (Permissive)", arguments: [
        "2025-12-29T10:00:00Z",
        "2025-12-29T10:00:00+07:00",
        "2025-12-29T10:00:00-05:00",
    ])
    func ignoresOffsets_rfc3339(input: String) {
        // All should parse to the same LOCAL time
        let ndt = NaiveDateTime(rfc3339: input)
        #expect(ndt != nil)
        #expect(ndt?.hour == 10)
    }

    @Test("NaiveDateTimeParserTests: Handles RFC3339 fractional seconds accurately", arguments: [
        ("2025-12-29T10:00:00.5", 500_000_000),
        ("2025-12-29T10:00:00.123456789", 123_456_789),
        ("2025-12-29T10:00:00,500", 500_000_000) // Comma separator
    ])
    func fractions_rfc3339(input: String, expectedNanos: Int) {
        let ndt = NaiveDateTime(rfc3339: input)
        #expect(ndt?.nanosecond == expectedNanos)
    }

    @Test("NaiveDateTimeParserTests: Fails on invalid RFC3339 dates", arguments: [
        "2025-02-29T10:00:00", // Not a leap year
        "2025-13-01T10:00:00", // Month 13
        "2025-12-32T10:00:00", // Day 32
        "2025-12-29T25:00:00" // Hour 25
    ])
    func invalidDates_rfc3339(input: String) {
        // parser.parse might succeed, but NaiveDateTime.init? should return nil
        let ndt = NaiveDateTime(rfc3339: input)
        #expect(ndt == nil)
    }

    @Test("NaiveDateTimeParserTests: Fails RFC3339 on garbage strings", arguments: [
        "Not a date",
        "2025-12",
        "T10:00:00"
    ])
    func garbage_rfc3339(input: String) {
        #expect(NaiveDateTime(rfc3339: input) == nil)
    }
}

// MARK: - RFC 5322 Tests

extension NaiveDateTimeParserTests {
    @Test("NaiveDateTimeParserTests: Valid RFC5322 DateTime strings", arguments: [
        // (Input, Year, Month, Day, Hour, Min, Sec)
        ("13 Apr 2026 13:46", 2026, 4, 13, 13, 46, 0),
        ("Mon, 13 Apr 2026 13:46:11", 2026, 4, 13, 13, 46, 11),
        (" 1 Jan 0001 00:00:00", 1, 1, 1, 0, 0, 0),
        ("31 Dec 9999 23:59:59.999", 9999, 12, 31, 23, 59, 59),
    ])
    // swiftlint:disable:next function_parameter_count
    func validParsing_rfc5322(
        input: String,
        year: Int32,
        month: Int,
        day: Int,
        hour: Int,
        min: Int,
        sec: Int
    ) {
        let ndt = NaiveDateTime(rfc5322: input)
        #expect(ndt != nil)
        #expect(ndt?.year == year)
        #expect(ndt?.month == month)
        #expect(ndt?.day == day)
        #expect(ndt?.hour == hour)
        #expect(ndt?.minute == min)
        #expect(ndt?.second == sec)
    }

    @Test("NaiveDateTimeParserTests: RFC5322 flexible whitespace and case", arguments: [
        "mon, 13 apr 2026 13:46:11", // Lowercase
        "13   Apr   2026   13:46", // Multiple spaces (FWS)
        "Mon,\r\n 13 Apr 2026 13:46", // Folding white space with CRLF
    ])
    func flexibility_rfc5322(input: String) {
        let ndt = NaiveDateTime(rfc5322: input)
        #expect(ndt != nil)
        #expect(ndt?.day == 13)
        #expect(ndt?.month == 4)
    }

    @Test("NaiveDateTimeParserTests: RFC5322 Failure Cases", arguments: [
        "Mon 13 Apr 2026 13:46", // Missing comma after weekday
        "13 Apr 2026 13:46 +0700", // Trailing offset (NaiveDateTime must end at time)
        "13 Apr 2026", // Missing time component
        "31 Feb 2026 13:46", // Invalid calendar date
        "13 Apr 2026 13:46:60", // Invalid seconds
    ])
    func failures_rfc5322(input: String) {
        #expect(NaiveDateTime(rfc5322: input) == nil)
    }
}
