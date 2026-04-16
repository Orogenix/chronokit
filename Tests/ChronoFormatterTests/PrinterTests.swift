import ChronoCore
@testable import ChronoFormatter
import Testing

struct ChronoPrinterTests {
    @Test("ChronoPrinterTests: Print Date")
    func testPrintDate() throws {
        let date = try #require(NaiveDate(year: 2026, month: 4, day: 16))
        let result = withBuffer(capacity: 10) { buffer, cursor in
            ChronoPrinter.printDate(date: date, to: buffer, at: &cursor)
        }
        #expect(result == "2026-04-16")
    }

    @Test("ChronoPrinterTests: Print Time")
    func testPrintTime() throws {
        let time = try #require(NaiveTime(hour: 12, minute: 30, second: 05))
        let result = withBuffer(capacity: 8) { buffer, cursor in
            ChronoPrinter.printTime(time: time, to: buffer, at: &cursor)
        }
        #expect(result == "12:30:05")
    }

    @Test("ChronoPrinterTests: Print Fraction with Padding")
    func testPrintFraction() {
        // Test 0 nanoseconds with 3 digits -> .000
        let result = withBuffer(capacity: 4) { buffer, cursor in
            ChronoPrinter.printFraction(0, digits: 3, to: buffer, at: &cursor)
        }
        #expect(result == ".000")
    }

    @Test("ChronoPrinterTests: Print Offset Zulu vs Fixed")
    func testPrintOffset() {
        // Test UTC
        let zulu = withBuffer(capacity: 1) { buffer, cursor in
            ChronoPrinter.printOffset(0, to: buffer, at: &cursor)
        }
        #expect(zulu == "Z")

        // Test +07:00
        let positive = withBuffer(capacity: 6) { buffer, cursor in
            ChronoPrinter.printOffset(25200, to: buffer, at: &cursor)
        }
        #expect(positive == "+07:00")
    }

    // MARK: - Helpers

    private func withBuffer(capacity: Int, action: (UnsafeMutableRawBufferPointer, inout Int) -> Void) -> String {
        let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        defer { ptr.deallocate() }
        let buffer = UnsafeMutableRawBufferPointer(start: ptr, count: capacity)

        var cursor = 0
        action(buffer, &cursor)

        return String(decoding: UnsafeRawBufferPointer(start: ptr, count: cursor), as: UTF8.self)
    }
}
