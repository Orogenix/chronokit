import ChronoCore
@testable import ChronoParser
import Testing

// MARK: - RFC 3339 Tests

struct DateParserTests {
    @Test("DateParserTests: Valid RFC 3339 Date String", arguments: [
        ("2025-12-29", 2025, 12, 29),
        ("1970-01-01", 1970, 01, 01),
        ("0001-01-01", 1, 1, 1),
        ("2024-02-29", 2024, 2, 29), // Leap year
    ])
    func validDateInit_rfc3339(input: String, year: Int32, month: Int, day: Int) {
        let date = NaiveDate(rfc3339: input)
        #expect(date != nil)
        #expect(date?.year == year)
        #expect(date?.month == month)
        #expect(date?.day == day)
    }

    @Test("DateParserTests: RFC 3339 Initializes from full DateTime<TZ>")
    func initFromDateTimeString_rfc3339() {
        let input = "2025-12-29T15:30:45.123Z"
        #expect(NaiveDate(rfc3339: input) == nil)
    }

    @Test("DateParserTests: RFC 3339 Fails on invalid formatting", arguments: [
        "2025/12/29", // Wrong separator
        "25-12-29", // Short year
        "2025-1-1", // Missing padding
        "NotADate" // Garbage
    ])
    func invalidFormat_rfc3339(input: String) {
        #expect(NaiveDate(rfc3339: input) == nil)
    }

    @Test("DateParserTests: RFC 3339 Fails on invalid calendar dates", arguments: [
        "2025-13-01", // Month 13
        "2025-04-31", // April 31
        "2023-02-29" // Not a leap year
    ])
    func invalidCalendar_rfc3339(input: String) {
        // This ensures the internal NaiveDate(year:month:day:) validation
        // or your parseParts validation is working through the init
        #expect(NaiveDate(rfc3339: input) == nil)
    }
}

// MARK: - RFC 5322 Tests

extension DateParserTests {
    @Test("DateParserTests: Valid RFC 5322 date strings", arguments: [
        ("13 Apr 2026", 2026, 4, 13),
        ("Mon, 13 Apr 2026", 2026, 4, 13),
        ("1 Jan 0001", 1, 1, 1),
        ("31 Dec 9999", 9999, 12, 31),
        ("29 Feb 2024", 2024, 2, 29), // Leap year
    ])
    func validDateInit_rfc5322(input: String, year: Int32, month: Int, day: Int) {
        let date = NaiveDate(rfc5322: input)
        #expect(date != nil)
        #expect(date?.year == year)
        #expect(date?.month == month)
        #expect(date?.day == day)
    }

    @Test("DateParserTests: RFC 5322 case insensitivity and whitespace", arguments: [
        ("mon, 13 apr 2026", 2026, 4, 13), // Lowercase
        ("MON, 13 APR 2026", 2026, 4, 13), // Uppercase
        ("13   Apr   2026", 2026, 4, 13), // Multiple spaces (FWS)
    ])
    func flexibleFormatting_rfc5322(input: String, year: Int32, month: Int, day: Int) {
        let date = NaiveDate(rfc5322: input)
        #expect(date != nil)
        #expect(date?.year == year)
        #expect(date?.month == month)
        #expect(date?.day == day)
    }

    @Test("DateParserTests: RFC 5322 failure cases", arguments: [
        "13 April 2026", // Full month name (must be 3 chars)
        "Mon 13 Apr 2026", // Missing comma after weekday
        "13-Apr-2026", // Wrong separators
        "32 Dec 2025", // Invalid calendar day
        "13 Apr 26", // 2-digit year (RFC 5322 mandates 4-digit in modern use)
    ])
    func invalidFormat_rfc5322(input: String) {
        #expect(NaiveDate(rfc5322: input) == nil)
    }
}
