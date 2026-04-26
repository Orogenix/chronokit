import ChronoCore
@testable import ChronoParser
import Testing

// MARK: - RFC 3339 Tests

struct TimeParserTests {
    @Test("TimeParserTests: Valid RFC 3339 Time Strings", arguments: [
        ("00:00:00", 0, 0, 0, 0),
        ("23:59:59", 23, 59, 59, 0),
        ("12:30:45.5", 12, 30, 45, 500_000_000),
        ("12:30:45.123456789", 12, 30, 45, 123_456_789),
        ("12:30:45,888", 12, 30, 45, 888_000_000), // ISO 8601 comma support
    ])
    func validTimes_rfc3339(input: String, h: Int, m: Int, s: Int, ns: Int) {
        let time = PlainTime(rfc3339: input)
        #expect(time != nil)
        #expect(time?.hour == h)
        #expect(time?.minute == m)
        #expect(time?.second == s)
        #expect(time?.nanosecond == ns)
    }

    @Test("TimeParserTests: RFC 3339 Failure Cases", arguments: [
        "12:30:45Z", // Offset present (Z)
        "12:30:45+07:00", // Offset present (+07:00)
        "12:30:45 ", // Trailing whitespace
        "T12:30:45", // Leading 'T' (PlainTime shouldn't ignore this)
        "12:30", // Missing seconds
        "24:00:00" // Out of range (handled by PlainTime internal init)
    ])
    func strictFailureCases_rfc3339(input: String) {
        #expect(PlainTime(rfc3339: input) == nil)
    }

    @Test("TimeParserTests: RFC 3339 Whole string consumption")
    func consumptionCheck_rfc3339() {
        // "12:30:45" is a valid time, but followed by a space/offset,
        // PlainTime(rfc5322:) should fail because of the cursor == raw.count check.
        let input = "12:30:45 "
        #expect(PlainTime(rfc3339: input) == nil)
    }
}

// MARK: - RFC 5322 Tests

extension TimeParserTests {
    @Test("TimeParserTests: Valid RFC 5322 time strings", arguments: [
        ("12:30", 12, 30, 0, 0), // Optional seconds omitted
        ("12:30:45", 12, 30, 45, 0), // Standard with seconds
        ("12:30:45.123", 12, 30, 45, 123_000_000), // Seconds + Fractions
        ("00:00:00", 0, 0, 0, 0), // Zero case
        ("23:59", 23, 59, 0, 0), // Upper bound without seconds
    ])
    func validTimes_rfc5322(input: String, h: Int, m: Int, s: Int, ns: Int) {
        let time = PlainTime(rfc5322: input)
        #expect(time != nil)
        #expect(time?.hour == h)
        #expect(time?.minute == m)
        #expect(time?.second == s)
        #expect(time?.nanosecond == ns)
    }

    @Test("TimeParserTests: RFC 5322 Failure Cases", arguments: [
        "12:30:45 +0700", // Contains offset (PlainTime should be pure)
        "12:30:45. ", // Dot without digits
        "12:3", // Missing digit in minute
        "9:30:00", // Missing padding in hour (RFC 5322 requires 2-digit hour)
        "12:30:60", // Invalid second (leap second not handled by PlainTime)
        "24:00", // Out of range hour
    ])
    func failureCases_rfc5322(input: String) {
        #expect(PlainTime(rfc5322: input) == nil)
    }

    @Test("TimeParserTests: RFC 5322 Whole string consumption")
    func consumptionCheck_rfc5322() {
        // "12:30:45" is a valid time, but followed by a space/offset,
        // PlainTime(rfc5322:) should fail because of the cursor == raw.count check.
        let input = "12:30:45 "
        #expect(PlainTime(rfc5322: input) == nil)
    }
}

// MARK: - RFC 2822 Tests

extension TimeParserTests {
    @available(*, deprecated)
    @Test("TimeParserTests: RFC 2822 alias yields identical results to RFC 5322")
    func redirectedDeprecation_rfc2822() {
        let date = "12:30:45"
        let modern = PlainTime(rfc5322: date)
        let deprecated = PlainTime(rfc2822: date)
        #expect(deprecated != nil)
        #expect(deprecated == modern)
    }
}
