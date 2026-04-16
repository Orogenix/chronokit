import ChronoCore
@testable import ChronoFormatter
import Testing

struct NaiveDateTimeFormatterTests {
    let dt = NaiveDateTime(
        year: 2026, month: 12, day: 29,
        hour: 15, minute: 30, second: 0,
        nanosecond: 500_000_000
    )

    @Test("NaiveDateTimeFormatterTests: Default string RFC3339 formatting")
    func defaultCombinedFormatting_rfc3339() throws {
        let datetime = try #require(dt, "Sample naive date time should valid")
        #expect(datetime.rfc3339() == "2026-12-29T15:30:00")
        #expect(datetime.description == "2026-12-29T15:30:00")
        #expect("Today is \(datetime)" == "Today is 2026-12-29T15:30:00")
    }

    @Test("NaiveDateTimeFormatterTests: Combined string with custom precision", arguments: [
        (3, "2026-12-29T15:30:00.500"),
        (0, "2026-12-29T15:30:00"),
    ])
    func combinedPrecision_rfc3339(digits: Int, expected: String) throws {
        let datetime = try #require(dt, "Sampe naive date time should valid")
        #expect(datetime.rfc3339(digits: digits) == expected)
    }

    @Test("NaiveDateTimeFormatterTests: Naive with Fixed Offset")
    func withOffset_rfc3339() throws {
        let dt = NaiveDateTime(year: 2026, month: 4, day: 16, hour: 13, minute: 0, second: 0)
        let naive = try #require(dt)
        let offset = FixedOffset(seconds: 25200) // +07:00
        let result = naive.rfc3339(digits: 0, offset: offset)
        #expect(result == "2026-04-16T13:00:00+07:00")
    }

    @Test("NaiveDateTimeFormatterTests: Naive with UTC Offset (Zulu)")
    func withUTCOffset_rfc3339() throws {
        let dt = NaiveDateTime(year: 2026, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        let naive = try #require(dt)
        let result = naive.rfc3339(digits: 0, offset: .utc)
        #expect(result == "2026-01-01T00:00:00Z", "Should print zulu offset")
    }

    @Test("NaiveDateTimeFormatterTests: Fractions and Offsets Combined")
    func fractionsAndOffsets_rfc3339() throws {
        let dt = NaiveDateTime(year: 2026, month: 4, day: 16, hour: 13, minute: 0, second: 0, nanosecond: 123_456_789)
        let naive = try #require(dt)
        let offset = FixedOffset(seconds: -18000) // -05:00
        #expect(naive.rfc3339(digits: 3, offset: offset) == "2026-04-16T13:00:00.123-05:00")
        #expect(naive.rfc3339(digits: 9, offset: offset) == "2026-04-16T13:00:00.123456789-05:00")
    }

    @Test("NaiveDateTimeFormatterTests: Max Digits Padding")
    func fractionPadding_rfc3339() throws {
        let dt = NaiveDateTime(year: 2026, month: 4, day: 16, hour: 12, minute: 0, second: 0, nanosecond: 0)
        let naive = try #require(dt)
        #expect(naive.rfc3339(digits: 3) == "2026-04-16T12:00:00.000", "Should print .000 even if nanos is 0")
    }
}
