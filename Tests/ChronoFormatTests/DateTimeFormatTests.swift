import ChronoCore
@testable import ChronoFormat
import Testing

@Suite("Date Time Format Tests")
struct DateTimeFormatTests {
    @Test("DateTimeFormatTests: DateTime uses its internal timezone offset", arguments: [
        // UTC+7 (Jakarta)
        (7 * 3600, "2025-12-29T16:00:00+07:00"),
        // UTC-5 (New York)
        (-5 * 3600, "2025-12-29T16:00:00-05:00"),
        // UTC (Zulu)
        (0, "2025-12-29T16:00:00Z"),
    ])
    func dateTimeOffsetFormatting(offsetSeconds: Int, expected: String) {
        // Setup a DateTime with a specific timezone offset
        // We use includeOffset: true and useZulu: true to verify the full logic
        let formatter = ChronoFormatter.iso8601(includeOffset: true, useZulu: true)

        let tz = FixedOffset(.seconds(offsetSeconds))
        let dt = DateTime(
            year: 2025, month: 12, day: 29,
            hour: 16, minute: 0, second: 0, nanosecond: 0,
            timezone: tz,
        )!

        let result = dt.string(with: formatter)
        #expect(result == expected)
    }

    @Test("DateTimeFormatTests: DateTime default string (ISO8601 no offset)")
    func dateTimeDefaultFormatting() {
        let tz = FixedOffset(.hours(1))
        let dt = DateTime(
            year: 2025, month: 12, day: 29,
            hour: 10, minute: 0, second: 0, nanosecond: 0,
            timezone: tz,
        )!

        #expect(
            dt.string() == "2025-12-29T10:00:00",
            "Default formatter is .iso8601(), which has includeOffset: false",
        )
    }

    @Test("DateTimeFormatTests: DateTime with fractional precision and offset")
    func dateTimeFractionAndOffset() {
        let tz = FixedOffset(.hours(-5))
        let dt = DateTime(
            year: 2025, month: 12, day: 29,
            hour: 12, minute: 0, second: 0,
            nanosecond: 500_000_000,
            timezone: tz,
        )!

        let formatter = ChronoFormatter.iso8601(digits: 3, includeOffset: true)
        #expect(dt.string(with: formatter) == "2025-12-29T12:00:00.500-05:00")
    }

    @Test("DateTimeFormatTests: NaiveDateTime description format")
    func naiveDateTimeDescription() {
        let date = NaiveDate(year: 2025, month: 12, day: 25)!
        let time = NaiveTime(hour: 14, minute: 30, second: 05, nanosecond: 123_456_789)!
        let dt = NaiveDateTime(date: date, time: time)

        #expect(dt.description == "2025-12-25T14:30:05.123456789")
    }

    @Test("DateTimeFormatTests: DateTime Zulu (UTC) formatting", arguments: [
        (0, "2024-12-25T13:50:05.000000000Z"),
        (3600, "2024-12-25T14:50:05.000000000+01:00"),
        (-18000, "2024-12-25T08:50:05.000000000-05:00")
    ])
    func dateTimeOffsets(offsetSeconds: Int, expected: String) {
        let instant = Instant(seconds: 1_735_134_605, nanoseconds: 0)
        let timezone = FixedOffset(seconds: offsetSeconds)
        let dt = DateTime(instant: instant, timezone: timezone)

        #expect(dt.description == expected)
    }

    @Test("DateTimeFormatTests: Padding check for early dates and times")
    func paddingCheck() {
        let dt = NaiveDateTime(
            date: .init(year: 8, month: 3, day: 9)!,
            time: .init(hour: 4, minute: 5, second: 6, nanosecond: 7)!,
        )

        // Verifies write4, write2, and writeFraction (9 digits) padding
        #expect(dt.description == "0008-03-09T04:05:06.000000007")
    }
}
