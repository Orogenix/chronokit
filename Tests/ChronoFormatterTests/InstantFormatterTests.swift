import ChronoCore
@testable import ChronoFormatter
import Testing

struct InstantFormatterTests {
    @Test("InstantFormatterTests: Unix Epoch")
    func epoch_rfc3339() {
        let epoch = Instant(seconds: 0, nanoseconds: 0)
        // Default (no digits) should be YYYY-MM-DDTHH:MM:SSZ
        #expect(epoch.rfc3339() == "1970-01-01T00:00:00Z")
        #expect(epoch.description == "1970-01-01T00:00:00Z")
        #expect("Today is \(epoch)" == "Today is 1970-01-01T00:00:00Z")
    }

    @Test("InstantFormatterTests: Recent Date with Milliseconds")
    func recentDate_rfc3339() {
        // 2026-04-16T12:00:00.500Z
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 500_000_000)
        #expect(instant.rfc3339(digits: 3) == "2026-04-16T12:00:00.500Z")
        #expect(instant.rfc3339(digits: 0) == "2026-04-16T12:00:00Z")
    }

    @Test("InstantFormatterTests: Full Nanosecond Precision")
    func nanosecondPrecision_rfc3339() {
        let instant = Instant(seconds: 1_776_340_800, nanoseconds: 123_456_789)
        #expect(instant.rfc3339(digits: 9) == "2026-04-16T12:00:00.123456789Z")
        #expect(instant.rfc3339(digits: 6) == "2026-04-16T12:00:00.123456Z")
    }

    @Test("InstantFormatterTests: Trailing Zeroes in Fractions")
    func trailingZeroes_rfc3339() {
        let instant = Instant(seconds: 100, nanoseconds: 0)
        // Ensure it correctly pads zeroes even when the fraction value is 0
        #expect(instant.rfc3339(digits: 3) == "1970-01-01T00:01:40.000Z")
    }

    @Test("InstantFormatterTests: Pre-Epoch Date")
    func preEpoch_rfc3339() {
        // 1969-12-31T23:59:59Z
        let instant = Instant(seconds: -1, nanoseconds: 0)
        #expect(instant.rfc3339() == "1969-12-31T23:59:59Z")
    }

    @Test("InstantFormatterTests: Capacity Safety check")
    func maxPossibleLength_rfc3339() {
        // Max theoretical length:
        // 10 (date) + 1 (T) + 8 (time) + 1 (.) + 9 (nanos) + 1 (Z) = 30 bytes.
        // Your capacity is 32, so this should never overflow.
        let instant = Instant(seconds: 253_402_300_799, nanoseconds: 999_999_999) // Year 9999
        #expect(instant.rfc3339(digits: 9).count <= 32)
        #expect(instant.rfc3339(digits: 9) == "9999-12-31T23:59:59.999999999Z")
    }
}
