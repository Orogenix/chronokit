import ChronoCore
@testable import ChronoFormat
import Testing

@Suite("Calendar Interval Format Tests")
struct CalendarIntervalTests {
    @Test("CalendarIntervalTests: Standard Date-only Intervals", arguments: [
        (0, 0, 0, "P0D"), // 0 Interval
        (12, 0, 0, "P1Y"), // Exactly 1 year
        (13, 2, 0, "P1Y1M2D"), // Normalized years and months
        (0, 45, 0, "P45D"), // Days only
        (1, 0, 0, "P1M"), // One month
        (0, 0, 3_600_000_000_000, "PT1H"), // One hour
        (0, 0, 60_000_000_000, "PT1M"), // One minute
    ])
    func dateIntervals(month: Int32, day: Int32, nano: Int64, expected: String) {
        let interval = CalendarInterval(month: month, day: day, nanosecond: nano)
        #expect(interval.description == expected)
    }

    @Test("CalendarIntervalTests: Time-only and Mixed Intervals", arguments: [
        (0, 0, 3600 * 1_000_000_000, "PT1H"), // 1 Hour
        (0, 0, 61 * 1_000_000_000, "PT1M1S"), // 1 Min 1 Sec
        (1, 1, 3661 * 1_000_000_000, "P1M1DT1H1M1S"), // Mixed Date/Time
    ])
    func timeIntervals(month: Int32, day: Int32, nano: Int64, expected: String) {
        let interval = CalendarInterval(month: month, day: day, nanosecond: nano)
        #expect(interval.description == expected)
    }

    @Test("CalendarIntervalTests: Fractional Seconds (Nanoseconds)")
    func fractionalSeconds() {
        // Test exactly 0.5 seconds (500,000,000 nanos)
        let halfSecond = CalendarInterval(month: 0, day: 0, nanosecond: 500_000_000)
        #expect(halfSecond.description == "PT0.500000000S")

        // Test 1.000000001 seconds
        let microNano = CalendarInterval(month: 0, day: 0, nanosecond: 1_000_000_001)
        #expect(microNano.description == "PT1.000000001S")
    }

    @Test("CalendarIntervalTests: Zero Interval Edge Case")
    func zeroInterval() {
        // Should produce P0D per your logic
        let zero = CalendarInterval(month: 0, day: 0, nanosecond: 0)
        #expect(zero.description == "P0D")
    }

    @Test("CalendarIntervalTests: Negative Intervals (Floor Math check)")
    func negativeIntervals() {
        // -13 months should be -2 years, +11 months if using floorDiv/floorMod correctly
        // Or -1Y -1M depending on how your specific floor logic maps to ISO8601
        // Given your logic: let years = floorDiv(-13, 12) -> -2
        // let remMonths = floorMod(-13, 12) -> 11
        let negInterval = CalendarInterval(month: -13, day: 0, nanosecond: 0)
        #expect(negInterval.description == "P-2Y11M")
    }

    @Test("CalendarIntervalTests: Buffer Overflow Safety")
    func bufferSafety() {
        let interval = CalendarInterval(month: 100, day: 100, nanosecond: 100_000_000_000)

        // Use a tiny buffer to trigger the guard in writeByte/writeVarInt
        let smallBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 2, alignment: 1)
        defer { smallBuffer.deallocate() }

        let written = interval.iso8601(to: smallBuffer)

        // It should stop writing at the buffer limit (2)
        #expect(written <= 2)
    }
}
