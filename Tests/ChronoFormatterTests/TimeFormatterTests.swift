import ChronoCore
@testable import ChronoFormatter
import Testing

struct TimeFormatterTests {
    let sampleTime = NaiveTime(hour: 14, minute: 05, second: 09, nanosecond: 123_456_789)

    @Test("TimeFormatTests: Default string representation uses timeHyphen")
    func defaultTimeFormatting_rfc3339() throws {
        let time = try #require(sampleTime, "sampleTime should exist")
        #expect(time.rfc3339() == "14:05:09", "Should use zero digits by default")
        #expect(time.description == "14:05:09", "Should use default RFC3339 for description")
        #expect("Now is \(time)" == "Now is 14:05:09")
    }

    @Test("TimeFormatterTests: Padding check for early morning times")
    func earlyTimePadding_rfc3339() throws {
        let earlyTime = try #require(NaiveTime(hour: 0, minute: 9, second: 5, nanosecond: 0))
        #expect(earlyTime.rfc3339() == "00:09:05")
    }

    @Test("TimeFormatterTests: Time with fractional seconds via extension", arguments: [
        (1, "14:05:09.1"),
        (9, "14:05:09.123456789"),
    ])
    func timeFractions_rfc3339(digits: Int, expectedSuffix: String) throws {
        // Even though default is timeHyphen, users can pass a custom ISO or Space strategy
        let time = try #require(sampleTime, "sampleTime should exist")
        let result = time.rfc3339(digits: digits)
        #expect(result.hasSuffix(expectedSuffix))
    }

    @Test("TimeFormatterTests: Standard time formatting", arguments: [
        (14, 30, 05, "14:30:05"),
        (23, 59, 59, "23:59:59"),
        (0, 0, 0, "00:00:00"), // Midnight
    ])
    func standardFormatting_rfc3339(hour: Int, minute: Int, second: Int, expected: String) throws {
        let time = try #require(NaiveTime(hour: hour, minute: minute, second: second))
        #expect(time.description == expected)
    }

    @Test("TimeFormatterTests: Padding for single-digit components")
    func paddingTest_rfc3339() throws {
        // Verifies that FixedWriter.write2 adds leading zeros correctly
        let time = try #require(NaiveTime(hour: 9, minute: 5, second: 1))
        #expect(time.description == "09:05:01")
    }

    @Test("TimeFormatTests: Noon and Midnight boundaries")
    func boundaries_rfc3339() throws {
        let noon = try #require(NaiveTime(hour: 12, minute: 0, second: 0))
        #expect(noon.description == "12:00:00")

        let midnight = NaiveTime.midnight
        #expect(midnight.description == "00:00:00")
    }
}
