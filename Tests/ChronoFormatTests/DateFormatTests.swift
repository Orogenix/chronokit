import ChronoCore
@testable import ChronoFormat
import Testing

@Suite("Date Format Tests")
struct DateFormatTests {
    @Test("DateFormatTests: Default string formatting (Midnight check)", arguments: [
        (NaiveDate(year: 2025, month: 1, day: 1)!, "2025-01-01"),
        (NaiveDate(year: 2024, month: 2, day: 29)!, "2024-02-29"), // Leap Year
        (NaiveDate(year: 9999, month: 12, day: 31)!, "9999-12-31"), // Bounds
    ])
    func defaultFormatting(date: NaiveDate, expected: String) {
        // Verifies the @_disfavoredOverload works and defaults to .dateHyphen
        #expect(date.string() == expected)
    }

    @Test("DateFormatTests: Protocol dispatch with ISO strategies", arguments: [
        // Ensure that even though it's a 'Date', it can render ISO with midnight time
        (ChronoFormatter.iso8601(), "2025-12-29T00:00:00"),
        (ChronoFormatter.dateTimeSpace(digits: 3), "2025-12-29 00:00:00.000")
    ])
    func dateWithComplexFormatters(strategy: ChronoFormatter, expected: String) {
        let date = NaiveDate(year: 2025, month: 12, day: 29)!
        #expect(date.string(with: strategy) == expected)
    }

    @Test("DateFormatTests: Consistency with FixedWriter padding")
    func paddingConsistency() {
        // Specifically testing if the convenience method preserves the FixedWriter's 0-padding
        let earlyDate = NaiveDate(year: 1, month: 1, day: 1)!
        #expect(earlyDate.string() == "0001-01-01")
    }

    @Test("DateFormatTests: Standard date formatting", arguments: [
        (2025, 12, 25, "2025-12-25"),
        (1999, 1, 1, "1999-01-01"),
        (2024, 2, 29, "2024-02-29") // Leap year
    ])
    func standardFormatting(year: Int32, month: Int, day: Int, expected: String) {
        let date = NaiveDate(year: year, month: month, day: day)!
        #expect(date.description == expected)
    }

    @Test("DateFormatTests: Padding for single-digit months and days")
    func paddingTest() {
        // Tests FixedWriter.write2 logic for leading zeros
        let date = NaiveDate(year: 2025, month: 5, day: 3)!
        #expect(date.description == "2025-05-03")
    }

    @Test("DateFormatTests: Early year padding (0-999)")
    func earlyYearPadding() {
        // Tests FixedWriter.write4 logic for years with leading zeros
        let date = NaiveDate(year: 8, month: 10, day: 12)!
        #expect(date.description == "0008-10-12")

        let medievalDate = NaiveDate(year: 450, month: 1, day: 1)!
        #expect(medievalDate.description == "0450-01-01")
    }

    @Test("DateFormatTests: Maximum and Minimum supported years")
    func extremeYearPadding() {
        let futureDate = NaiveDate(year: 9999, month: 12, day: 31)!
        #expect(futureDate.description == "9999-12-31")

        let zeroDate = NaiveDate(year: 0, month: 1, day: 1)!
        #expect(zeroDate.description == "0000-01-01")
    }
}
