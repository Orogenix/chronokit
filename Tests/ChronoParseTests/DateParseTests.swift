import ChronoCore
@testable import ChronoParse
import Testing

@Suite("Date Parse Tests")
struct DateParseTests {
    @Test("DateParseTests: Valid date-only strings", arguments: [
        ("2025-12-29", 2025, 12, 29),
        ("1970-01-01", 1970, 01, 01),
        ("0001-01-01", 1, 1, 1),
        ("2024-02-29", 2024, 2, 29), // Leap year
    ])
    func validDateInit(input: String, year: Int, month: Int, day: Int) {
        let date = NaiveDate(input)

        #expect(date != nil)
        #expect(date!.year == year)
        #expect(date!.month == UInt8(month))
        #expect(date!.day == UInt8(day))
    }

    @Test("DateParseTests: Initializes correctly from full DateTime strings")
    func initFromDateTimeString() {
        // NaiveDate should accept a full ISO string but only store the date parts
        let input = "2025-12-29T15:30:45.123Z"
        let date = NaiveDate(input)

        #expect(date != nil)
        #expect(date!.year == 2025)
        #expect(date!.month == 12)
        #expect(date!.day == 29)
    }

    @Test("DateParseTests: Fails on invalid formatting", arguments: [
        "2025/12/29", // Wrong separator
        "25-12-29", // Short year
        "2025-1-1", // Missing padding
        "NotADate" // Garbage
    ])
    func invalidFormat(input: String) {
        #expect(NaiveDate(input) == nil)
    }

    @Test("DateParseTests: Fails on invalid calendar dates", arguments: [
        "2025-13-01", // Month 13
        "2025-04-31", // April 31
        "2023-02-29" // Not a leap year
    ])
    func invalidCalendar(input: String) {
        // This ensures the internal NaiveDate(year:month:day:) validation
        // or your parseParts validation is working through the init
        #expect(NaiveDate(input) == nil)
    }

    @Test("DateParseTests: Using custom parser strategy")
    func customParser() {
        // Strategy .expanded expects "YYYY-MM-DD HH:MM:SS"
        let input = "2025-12-29 15:00:00"
        let date = NaiveDate(input, with: .expanded)!

        #expect(date.year == 2025)
        #expect(date.day == 29)
    }
}
