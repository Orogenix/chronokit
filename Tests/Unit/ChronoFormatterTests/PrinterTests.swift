import ChronoCore
@testable import ChronoFormatter
import Testing

struct ChronoPrinterTests {
    @Test("ChronoPrinterTests: Print Date")
    func printDate() throws {
        let date = try #require(PlainDate(year: 2026, month: 4, day: 16))
        let result = withBuffer(capacity: 10) { buffer, cursor in
            ChronoPrinter.printDate(date, to: buffer, at: &cursor)
        }
        #expect(result == "2026-04-16")
    }

    @Test("ChronoPrinterTests: Print Fraction with Padding")
    func testPrintFraction() {
        // Test 0 nanoseconds with 3 digits -> .000
        let result = withBuffer(capacity: 4) { buffer, cursor in
            ChronoPrinter.printFraction(0, digits: 3, to: buffer, at: &cursor)
        }
        #expect(result == ".000")
    }

    @Test("ChronoPrinterTests: Print Offset RFC 3339")
    func testPrintOffsetRFC3339() {
        // Test UTC
        let zulu = withBuffer(capacity: 1) { buffer, cursor in
            ChronoPrinter.printOffsetRFC3339(0, to: buffer, at: &cursor)
        }
        #expect(zulu == "Z")

        // Test +07:00
        let positive = withBuffer(capacity: 6) { buffer, cursor in
            ChronoPrinter.printOffsetRFC3339(25200, to: buffer, at: &cursor)
        }
        #expect(positive == "+07:00")
    }

    @Test("ChronoPrinterTests: Print Offset RFC 5322 (No Colons)", arguments: [
        (0, "+0000"),
        (3600, "+0100"),
        (-18000, "-0500"),
        (34200, "+0930") // Test half-hour offsets (e.g., ACST)
    ])
    func testPrintOffsetRFC5322(seconds: Int, expected: String) {
        let result = withBuffer(capacity: 5) { buffer, cursor in
            ChronoPrinter.printOffsetRFC5322(seconds, to: buffer, at: &cursor)
        }
        #expect(result == expected)
    }
}

// MARK: - Textual Component Tests

extension ChronoPrinterTests {
    @Test("ChronoPrinterTests: Print Month Names")
    func testPrintMonth() {
        let cases: [(Month, String)] = [
            (.january, "Jan"), (.september, "Sep"), (.december, "Dec"),
        ]

        for (month, expected) in cases {
            let result = withBuffer(capacity: 3) { buffer, cursor in
                ChronoPrinter.printMonth(month, to: buffer, at: &cursor)
            }
            #expect(result == expected)
        }
    }

    @Test("ChronoPrinterTests: Print Weekday Names")
    func testPrintWeekday() {
        let cases: [(Weekday, String)] = [
            (.monday, "Mon"), (.wednesday, "Wed"), (.sunday, "Sun"),
        ]

        for (day, expected) in cases {
            let result = withBuffer(capacity: 3) { buffer, cursor in
                ChronoPrinter.printWeekday(day, to: buffer, at: &cursor)
            }
            #expect(result == expected)
        }
    }
}

// MARK: - Edge Cases & Fractions

extension ChronoPrinterTests {
    @Test("ChronoPrinterTests: Print Fraction with specific values")
    func printFractionValues() {
        // Test 123ms with 3 digits
        let ms = withBuffer(capacity: 4) { buffer, cursor in
            ChronoPrinter.printFraction(123_000_000, digits: 3, to: buffer, at: &cursor)
        }
        #expect(ms == ".123")

        // Test 0 digits (should write nothing)
        let none = withBuffer(capacity: 4) { buffer, cursor in
            ChronoPrinter.printFraction(123_000_000, digits: 0, to: buffer, at: &cursor)
        }
        #expect(none == "")

        // Test 0 nanoseconds with 3 digits -> .000
        let result = withBuffer(capacity: 4) { buffer, cursor in
            ChronoPrinter.printFraction(0, digits: 3, to: buffer, at: &cursor)
        }
        #expect(result == ".000")
    }

    @Test("ChronoPrinterTests: Buffer overflow guards")
    func guards() {
        // Month needs 3 bytes. Providing 2 should trigger the guard and return early.
        let result = withBuffer(capacity: 2) { buffer, cursor in
            ChronoPrinter.printMonth(.january, to: buffer, at: &cursor)
        }
        #expect(result == "")

        // Weekday needs 3 bytes.
        let result2 = withBuffer(capacity: 2) { buffer, cursor in
            ChronoPrinter.printWeekday(.friday, to: buffer, at: &cursor)
        }
        #expect(result2 == "")
    }
}

// MARK: - Helpers

extension ChronoPrinterTests {
    private func withBuffer(capacity: Int, action: (UnsafeMutableRawBufferPointer, inout Int) -> Void) -> String {
        let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        defer { ptr.deallocate() }
        let buffer = UnsafeMutableRawBufferPointer(start: ptr, count: capacity)

        var cursor = 0
        action(buffer, &cursor)

        return String(decoding: UnsafeRawBufferPointer(start: ptr, count: cursor), as: UTF8.self)
    }
}
