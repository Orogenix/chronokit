import ChronoCore
@testable import ChronoFormatter
import Testing

struct DateFormatterTests {
    @Test("DateFormatterTests: Default string formatting (Midnight check)", arguments: [
        (NaiveDate(year: 2025, month: 1, day: 1), "2025-01-01"),
        (NaiveDate(year: 2024, month: 2, day: 29), "2024-02-29"), // Leap Year
        (NaiveDate(year: 9999, month: 12, day: 31), "9999-12-31"), // Bounds
    ])
    func formatting_rfc3339(date: NaiveDate?, expected: String) throws {
        let requiredDate = try #require(date)
        #expect(requiredDate.rfc3339() == expected)
        #expect(requiredDate.description == expected)
        #expect("Today is \(requiredDate)" == "Today is \(expected)")
    }

    @Test("DateFormatterTests: Consistency with FixedWriter padding")
    func paddingConsistency_rfc3339() throws {
        // Specifically testing if the convenience method preserves the FixedWriter's 0-padding
        let earlyDate = try #require(NaiveDate(year: 1, month: 1, day: 1))
        #expect(earlyDate.rfc3339() == "0001-01-01")
    }

    @Test("DateFormatterTests: Standard date formatting", arguments: [
        (2025, 12, 25, "2025-12-25"),
        (1999, 1, 1, "1999-01-01"),
        (2024, 2, 29, "2024-02-29"), // Leap year
    ])
    func standardFormatting_rfc3339(year: Int32, month: Int, day: Int, expected: String) throws {
        let date = try #require(NaiveDate(year: year, month: month, day: day))
        #expect(date.description == expected)
    }

    @Test("DateFormatterTests: Padding for single-digit months and days")
    func paddingTest_rfc3339() throws {
        // Tests FixedWriter.write2 logic for leading zeros
        let date = try #require(NaiveDate(year: 2025, month: 5, day: 3))
        #expect(date.description == "2025-05-03")
    }

    @Test("DateFormatterTests: Early year padding (0-999)")
    func earlyYearPadding_rfc3339() throws {
        // Tests FixedWriter.write4 logic for years with leading zeros
        let date = try #require(NaiveDate(year: 8, month: 10, day: 12))
        #expect(date.description == "0008-10-12")

        let medievalDate = try #require(NaiveDate(year: 450, month: 1, day: 1))
        #expect(medievalDate.description == "0450-01-01")
    }

    @Test("DateFormatterTests: Maximum and Minimum supported years")
    func extremeYearPadding_rfc3339() throws {
        let futureDate = try #require(NaiveDate(year: 9999, month: 12, day: 31))
        #expect(futureDate.description == "9999-12-31")

        let zeroDate = try #require(NaiveDate(year: 0, month: 1, day: 1))
        #expect(zeroDate.description == "0000-01-01")
    }
}
