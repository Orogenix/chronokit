import ChronoCore
@testable import ChronoParser
import Testing

// MARK: RFC3339 Tests

struct TimeParserTests {
    @Test("TimeParserTests: Valid Time Strings", arguments: [
        ("00:00:00", 0, 0, 0, 0),
        ("23:59:59", 23, 59, 59, 0),
        ("12:30:45.5", 12, 30, 45, 500_000_000),
        ("12:30:45.123456789", 12, 30, 45, 123_456_789),
        ("12:30:45,888", 12, 30, 45, 888_000_000), // ISO 8601 comma support
    ])
    func validTimes_rfc3339(input: String, h: Int, m: Int, s: Int, ns: Int) {
        let time = NaiveTime(rfc3339: input)
        #expect(time != nil)
        #expect(time?.hour == h)
        #expect(time?.minute == m)
        #expect(time?.second == s)
        #expect(time?.nanosecond == ns)
    }

    @Test("TimeParserTests: Strict Completion (Failures)", arguments: [
        "12:30:45Z", // Offset present (Z)
        "12:30:45+07:00", // Offset present (+07:00)
        "12:30:45 ", // Trailing whitespace
        "T12:30:45", // Leading 'T' (NaiveTime shouldn't ignore this)
        "12:30", // Missing seconds
        "24:00:00" // Out of range (handled by NaiveTime internal init)
    ])
    func strictFailureCases_rfc3339(input: String) {
        // Because of result.consumed == raw.count, these should all return nil
        #expect(NaiveTime(rfc3339: input) == nil)
    }

    @Test("TimeParserTests: Performance Path: withUTF8 execution")
    func withUTF8Path_rfc3339() {
        // Ensuring our testing logic matches production storage patterns
        var input = "15:04:05.999"
        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0
            let result = ChronoScanner.scanTime(from: raw, at: &cursor)

            #expect(result != nil)
            #expect(cursor == buffer.count)
        }
    }
}
