import ChronoCore
@testable import ChronoFormat
import Testing

@Suite("Time Format Tests")
struct TimeFormatTests {
    let sampleTime = NaiveTime(hour: 14, minute: 05, second: 09, nanosecond: 123_456_789)!

    @Test("TimeFormatTests: Default string representation uses timeHyphen")
    func defaultTimeFormatting() {
        #expect(sampleTime.string() == "14:05:09", "Should use .timeHyphen strategy by default")
    }

    @Test("TimeFormatTests: Padding check for early morning times")
    func earlyTimePadding() {
        let earlyTime = NaiveTime(hour: 0, minute: 9, second: 5, nanosecond: 0)!
        #expect(earlyTime.string() == "00:09:05")
    }

    @Test("TimeFormatTests: Protocol dispatch with ISO strategies (Unix Epoch anchor)", arguments: [
        // Ensure that it uses 1970-01-01 when asked to render a date-time strategy
        (ChronoFormatter.iso8601(), "1970-01-01T14:05:09"),
        (ChronoFormatter.dateTimeSpace(digits: 3), "1970-01-01 14:05:09.123")
    ])
    func timeWithDateFormatters(strategy: ChronoFormatter, expected: String) {
        #expect(sampleTime.string(with: strategy) == expected)
    }

    @Test("TimeFormatTests: Time with fractional seconds via extension", arguments: [
        (1, "14:05:09.1"),
        (9, "14:05:09.123456789")
    ])
    func timeFractions(digits: Int, expectedSuffix: String) {
        // Even though default is timeHyphen, users can pass a custom ISO or Space strategy
        let formatter = ChronoFormatter.dateTimeSpace(digits: digits)
        let result = sampleTime.string(with: formatter)

        #expect(result.hasSuffix(expectedSuffix))
    }

    @Test("TimeFormatTests: Standard time formatting", arguments: [
        (14, 30, 05, "14:30:05"),
        (23, 59, 59, "23:59:59"),
        (0, 0, 0, "00:00:00") // Midnight
    ])
    func standardFormatting(hour: Int, minute: Int, second: Int, expected: String) {
        let time = NaiveTime(hour: hour, minute: minute, second: second)!
        #expect(time.description == expected)
    }

    @Test("TimeFormatTests: Padding for single-digit components")
    func paddingTest() {
        // Verifies that FixedWriter.write2 adds leading zeros correctly
        let time = NaiveTime(hour: 9, minute: 5, second: 1)!
        #expect(time.description == "09:05:01")
    }

    @Test("TimeFormatTests: Nanoseconds are ignored in timeHyphen strategy")
    func ignoreNanoseconds() {
        // The .timeHyphen strategy returns exactly 8 characters (HH:mm:ss)
        // Even if nanoseconds are present, they should not appear in the description.
        let time = NaiveTime(hour: 12, minute: 0, second: 0, nanosecond: 999_999_999)!
        #expect(time.description == "12:00:00")
        #expect(time.description.count == 8)
    }

    @Test("TimeFormatTests: Noon and Midnight boundaries")
    func boundaries() {
        let midnight = NaiveTime.midnight
        #expect(midnight.description == "00:00:00")

        let noon = NaiveTime(hour: 12, minute: 0, second: 0)!
        #expect(noon.description == "12:00:00")
    }
}
