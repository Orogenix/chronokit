import ChronoCore
@testable import ChronoFormatter
import Testing

// MARK: - RFC 3339 Tests

struct DateFormatterTests {
    @Test("DateFormatterTests: RFC 3339 formatting", arguments: [
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

    @Test("DateFormatterTests: Consistency RFC 3339 padding")
    func paddingConsistency_rfc3339() throws {
        // Specifically testing if the convenience method preserves the FixedWriter's 0-padding
        let earlyDate = try #require(NaiveDate(year: 1, month: 1, day: 1))
        #expect(earlyDate.rfc3339() == "0001-01-01")
    }

    @Test("DateFormatterTests: RFC 3339 padding for single-digit months and days")
    func paddingTest_rfc3339() throws {
        // Tests FixedWriter.write2 logic for leading zeros
        let date = try #require(NaiveDate(year: 2025, month: 5, day: 3))
        #expect(date.description == "2025-05-03")
    }

    @Test("DateFormatterTests: RFC 3339 early year padding (0-999)")
    func earlyYearPadding_rfc3339() throws {
        // Tests FixedWriter.write4 logic for years with leading zeros
        let date = try #require(NaiveDate(year: 8, month: 10, day: 12))
        #expect(date.description == "0008-10-12")

        let medievalDate = try #require(NaiveDate(year: 450, month: 1, day: 1))
        #expect(medievalDate.description == "0450-01-01")
    }

    @Test("DateFormatterTests: RFC 3339 Maximum and Minimum supported years")
    func extremeYearPadding_rfc3339() throws {
        let futureDate = try #require(NaiveDate(year: 9999, month: 12, day: 31))
        #expect(futureDate.description == "9999-12-31")

        let zeroDate = try #require(NaiveDate(year: 0, month: 1, day: 1))
        #expect(zeroDate.description == "0000-01-01")
    }
}

// MARK: - RFC 5322 Tests

extension DateFormatterTests {
    @Test("DateFormatterTests: RFC 5322 formatting", arguments: [
        (2025, 5, 3, "Sat, 03 May 2025"),
        (2024, 2, 29, "Thu, 29 Feb 2024"), // Leap year
        (2026, 1, 1, "Thu, 01 Jan 2026"), // Year transition
        (1990, 12, 25, "Tue, 25 Dec 1990"),
    ])
    func formatting_rfc5322(year: Int32, month: Int, day: Int, expected: String) throws {
        let date = try #require(NaiveDate(year: year, month: month, day: day))
        #expect(date.rfc5322() == expected)
    }

    @Test("DateFormatterTests: RFC 5322 edge years")
    func edgeYears_rfc5322() throws {
        // Year 0001
        let ancient = try #require(NaiveDate(year: 1, month: 1, day: 1))
        // 0001-01-01 was a Monday in many Proleptic Gregorian calendars
        #expect(ancient.rfc5322() == "Mon, 01 Jan 0001")

        // Year 9999
        let future = try #require(NaiveDate(year: 9999, month: 12, day: 31))
        #expect(future.rfc5322() == "Fri, 31 Dec 9999")
    }

    @Test("DateFormatterTests: RFC 5322 Month naming")
    func monthNaming_rfc5322() throws {
        let months = [
            (1, "Jan"), (2, "Feb"), (3, "Mar"), (4, "Apr"),
            (5, "May"), (6, "Jun"), (7, "Jul"), (8, "Aug"),
            (9, "Sep"), (10, "Oct"), (11, "Nov"), (12, "Dec"),
        ]

        for (m, expected) in months {
            let date = try #require(NaiveDate(year: 2025, month: m, day: 10))
            let result = try #require(date.rfc5322())
            #expect(result.contains(expected))
        }
    }

    @Test("DateFormatterTests: RFC 5322 weekday logic")
    func weekdayLogic_rfc5322() throws {
        // Checking specific known days to ensure ChronoMath calculation is right
        let mon = try #require(NaiveDate(year: 2025, month: 4, day: 14))
        #expect(mon.rfc5322()?.hasPrefix("Mon") == true)

        let sun = try #require(NaiveDate(year: 2025, month: 4, day: 20))
        #expect(sun.rfc5322()?.hasPrefix("Sun") == true)
    }
}

// MARK: - RFC 2822 Tests

extension DateFormatterTests {
    @available(*, deprecated)
    @Test("DateFormatterTests: RFC 2822 alias yields identical results to RFC 5322")
    func redirectedDeprecation_rfc2822() throws {
        let date = try #require(NaiveDate(year: 2026, month: 1, day: 1))
        let modern = date.rfc5322()
        let deprecated = date.rfc2822()
        #expect(deprecated != nil)
        #expect(deprecated == modern)
    }
}
