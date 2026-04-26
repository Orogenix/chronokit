import ChronoCore
@testable import ChronoFormatter
import Testing

// MARK: - RFC 3339 Tests

struct TimeFormatterTests {
    let sampleTime = PlainTime(hour: 14, minute: 05, second: 09, nanosecond: 123_456_789)

    @Test("TimeFormatTests: RFC 3339 sample time formatting")
    func defaultTimeFormatting_rfc3339() throws {
        let time = try #require(sampleTime, "sampleTime should exist")
        #expect(time.rfc3339() == "14:05:09", "Should use zero digits by default")
        #expect(time.description == "14:05:09", "Should use default RFC3339 for description")
        #expect("Now is \(time)" == "Now is 14:05:09")
    }

    @Test("TimeFormatterTests: RFC 3339 padding check")
    func earlyTimePadding_rfc3339() throws {
        let earlyTime = try #require(PlainTime(hour: 0, minute: 9, second: 5, nanosecond: 0))
        #expect(earlyTime.rfc3339() == "00:09:05")
    }

    @Test("TimeFormatterTests: RFC 3339 fractional check", arguments: [
        (0, "14:05:09"),
        (1, "14:05:09.1"),
        (3, "14:05:09.123"),
        (6, "14:05:09.123456"),
        (9, "14:05:09.123456789"),
        (20, "14:05:09.12345678900000000000"),
    ])
    func timeFractions_rfc3339(digits: Int, expected: String) throws {
        let time = try #require(sampleTime, "sampleTime should exist")
        #expect(time.rfc3339(digits: digits) == expected)
    }

    @Test("TimeFormatterTests: RFC 3339 sample time formatting", arguments: [
        (14, 30, 05, "14:30:05"),
        (23, 59, 59, "23:59:59"),
        (0, 0, 0, "00:00:00"), // Midnight
    ])
    func standardFormatting_rfc3339(hour: Int, minute: Int, second: Int, expected: String) throws {
        let time = try #require(PlainTime(hour: hour, minute: minute, second: second))
        #expect(time.description == expected)
    }

    @Test("TimeFormatterTests: RFC 3339 padding for single-digit components")
    func paddingTest_rfc3339() throws {
        // Verifies that FixedWriter.write2 adds leading zeros correctly
        let time = try #require(PlainTime(hour: 9, minute: 5, second: 1))
        #expect(time.description == "09:05:01")
    }

    @Test("TimeFormatTests: RFC 3339 noon and midnight boundaries")
    func boundaries_rfc3339() throws {
        let noon = try #require(PlainTime(hour: 12, minute: 0, second: 0))
        #expect(noon.description == "12:00:00")

        let midnight = PlainTime.midnight
        #expect(midnight.description == "00:00:00")
    }
}

// MARK: - RFC 5322 Tests

extension TimeFormatterTests {
    @Test("TimeFormatterTests: RFC 5322 standard time formatting", arguments: [
        (14, 05, 09, "14:05:09"),
        (0, 0, 0, "00:00:00"),
        (23, 59, 59, "23:59:59"),
    ])
    func formatting_rfc5322(hour: Int, minute: Int, second: Int, expected: String) throws {
        let time = try #require(PlainTime(hour: hour, minute: minute, second: second))
        #expect(time.rfc5322() == expected)
    }

    @Test("TimeFormatterTests: RFC 5322 fractional seconds with trailing zeros")
    func trailingZerosInFractions() throws {
        // Test 14:05:09.500...
        let time = try #require(PlainTime(hour: 14, minute: 5, second: 9, nanosecond: 500_000_000))

        #expect(time.rfc3339(digits: 3) == "14:05:09.500")
        #expect(time.rfc3339(digits: 1) == "14:05:09.5")
    }
}

// MARK: - RFC 2822 Tests

extension TimeFormatterTests {
    @available(*, deprecated)
    @Test("TimeFormatterTests: RFC 2822 alias yields identical results to RFC 5322")
    func redirectedDeprecation_rfc2822() throws {
        let time = try #require(PlainTime(hour: 0, minute: 0, second: 0))
        let modern = time.rfc5322()
        let deprecated = time.rfc2822()
        #expect(deprecated == modern)
    }
}
