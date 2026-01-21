@testable import ChronoKit
import ChronoMath
import Testing

@Suite("Calendar Interval Parse Tests")
struct CalendarIntervalParseTests {
    @inline(__always)
    func parse(_ string: String) -> CalendarInterval? {
        CalendarInterval(string)
    }

    @inline(__always)
    func expectNil(_ string: String, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(parse(string) == nil, sourceLocation: sourceLocation)
    }

    @inline(__always)
    func expect(
        _ string: String,
        month: Int32 = 0,
        day: Int32 = 0,
        nanosecond: Int64 = 0,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard let interval = parse(string) else {
            #expect(Bool(false), "Failed to parse '\(string)'", sourceLocation: sourceLocation)
            return
        }

        #expect(interval.month == month, sourceLocation: sourceLocation)
        #expect(interval.day == day, sourceLocation: sourceLocation)
        #expect(interval.nanosecond == nanosecond, sourceLocation: sourceLocation)
    }

    @Test("CalendarIntervalParseTests: Parse date component")
    func parseDateComponents() {
        expect("P1Y", month: 12)
        expect("P2M", month: 2)
        expect("P3D", day: 3)
        expect("P1Y2M3D", month: 14, day: 3)
    }

    @Test("CalendarIntervalParseTests: Parse time component")
    func parseTimeComponents() {
        expect("PT1H", nanosecond: NanoSeconds.perHour64)
        expect("PT2M", nanosecond: 2 * NanoSeconds.perMinute64)
        expect("PT3S", nanosecond: 3 * NanoSeconds.perSecond64)
    }

    @Test("CalendarIntervalParseTests: Parse date and time component")
    func parseDateAndTime() {
        expect(
            "P1Y2M3DT4H5M6S",
            month: 14,
            day: 3,
            nanosecond: 4 * NanoSeconds.perHour64
                + 5 * NanoSeconds.perMinute64
                + 6 * NanoSeconds.perSecond64
        )
    }

    @Test("CalendarIntervalParseTests: Parse fractional seconds component")
    func parseFractionalSeconds() {
        expect(
            "PT1.5S",
            nanosecond: NanoSeconds.perSecond64 + 500_000_000
        )

        expect(
            "PT0.000000001S",
            nanosecond: 1
        )

        expect(
            "PT10.123456789S",
            nanosecond: 10 * NanoSeconds.perSecond64 + 123_456_789
        )
    }

    @Test("CalendarIntervalParseTests: Parse invalid fractional seconds component")
    func rejectInvalidFractions() {
        expectNil("P1.5Y")
        expectNil("PT1.5H")
        expectNil("PT1.5M")
        expectNil("PT1.2S3.4S")
        expectNil("PT1.2S3M")
    }

    @Test("CalendarIntervalParseTests: Parse signed intervals")
    func parseSignedIntervals() {
        expect("-P1D", day: -1)
        expect("+P1D", day: 1)
        expect("-PT1H", nanosecond: -NanoSeconds.perHour64)
    }

    @Test("CalendarIntervalParseTests: Parse combined negative sign")
    func parseNegativeCombined() {
        expect(
            "-P1Y2M3DT4H",
            month: -(12 + 2),
            day: -3,
            nanosecond: -4 * NanoSeconds.perHour64
        )
    }

    @Test("CalendarIntervalParseTests: Parse normalized sign from zero")
    func zeroNormalizesSign() {
        expect("P0D", day: 0)
        expect("-P0D", day: 0)
        expect("+P0D", day: 0)
    }

    @Test("CalendarIntervalParseTests: Reject invalid structure")
    func rejectInvalidStructure() {
        expectNil("1D")
        expectNil("T1S")
        expectNil("PT")
        expectNil("P1DT")
        expectNil("PT1HT2S")
        expectNil("P")
        expectNil("+P")
        expectNil("-P")
        expectNil("P1DT2M1H")
        expectNil("P1M2Y")
    }

    @Test("CalendarIntervalParseTests: Reject overflow")
    func rejectOverflow() {
        expectNil("P9223372036854775807Y")
        expectNil("PT9223372036854775807S")
    }

    @Test("CalendarIntervalParseTests: Reject calendar interval narrowing overflow")
    func rejectCalendarIntervalNarrowingOverflow() {
        expectNil("P2147483648M")
        expectNil("-P2147483649M")
    }

    @Test("CalendarIntervalParseTests: Reject garbage input")
    func rejectGarbageInput() {
        expectNil("")
        expectNil("PX")
        expectNil("P1Q")
        expectNil("PT1Q")
        expectNil("P1Y1Y")
        expectNil("P1DXYZ")
    }
}
