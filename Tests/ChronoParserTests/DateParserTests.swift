import ChronoCore
@testable import ChronoParser
import Testing

// MARK: RFC3339 Tests

struct DateParserTests {
    @Test("DateParserTests: Valid date-only strings", arguments: [
        ("2025-12-29", 2025, 12, 29),
        ("1970-01-01", 1970, 01, 01),
        ("0001-01-01", 1, 1, 1),
        ("2024-02-29", 2024, 2, 29), // Leap year
    ])
    func validDateInit_rfc3339(input: String, year: Int32, month: Int, day: Int) {
        let date = NaiveDate(input, as: .rfc3339)
        #expect(date != nil)
        #expect(date?.year == year)
        #expect(date?.month == month)
        #expect(date?.day == day)
    }

    @Test("DateParserTests: Initializes correctly from full DateTime strings")
    func initFromDateTimeString_rfc3339() {
        // NaiveDate should accept a full ISO string but only store the date parts
        let input = "2025-12-29T15:30:45.123Z"
        let date = NaiveDate(input, as: .rfc3339)
        #expect(date != nil)
        #expect(date?.year == 2025)
        #expect(date?.month == 12)
        #expect(date?.day == 29)
    }

    @Test("DateParserTests: Fails on invalid formatting", arguments: [
        "2025/12/29", // Wrong separator
        "25-12-29", // Short year
        "2025-1-1", // Missing padding
        "NotADate" // Garbage
    ])
    func invalidFormat_rfc3339(input: String) {
        #expect(NaiveDate(input, as: .rfc3339) == nil)
    }

    @Test("DateParserTests: Fails on invalid calendar dates", arguments: [
        "2025-13-01", // Month 13
        "2025-04-31", // April 31
        "2023-02-29" // Not a leap year
    ])
    func invalidCalendar_rfc3339(input: String) {
        // This ensures the internal NaiveDate(year:month:day:) validation
        // or your parseParts validation is working through the init
        #expect(NaiveDate(input, as: .rfc3339) == nil)
    }
}
