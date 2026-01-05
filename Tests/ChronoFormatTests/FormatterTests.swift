import ChronoCore
@testable import ChronoFormat
import Testing

@Suite("ChronoFormatter Integration Tests")
struct ChronoFormatterTests {
    typealias Strategy = ChronoFormatter.Strategy
    let testDate = NaiveDate(year: 2025, month: 12, day: 31)!
    let testTime = NaiveTime(hour: 23, minute: 59, second: 58, nanosecond: 123_456_789)!

    @Test("Strategy Capacity and Formatting Match", arguments: [
        (
            strategy: Strategy.dateHyphen,
            offset: nil,
            expectedCap: 10,
            expectedStr: "2025-12-31"
        ),
        (
            strategy: Strategy.timeHyphen,
            offset: nil,
            expectedCap: 8,
            expectedStr: "23:59:58"
        ),
        (
            strategy: Strategy.dateTimeSpace(digits: 3),
            offset: nil,
            expectedCap: 19 + 4,
            expectedStr: "2025-12-31 23:59:58.123"
        ),
        (
            strategy: Strategy.iso8601(digits: 0, includeOffset: true, useZulu: true),
            offset: 0,
            expectedCap: 19 + 1,
            expectedStr: "2025-12-31T23:59:58Z"
        ),
        (
            strategy: Strategy.iso8601(digits: 9, includeOffset: true, useZulu: true),
            offset: 3600,
            expectedCap: 19 + 10 + 6,
            expectedStr: "2025-12-31T23:59:58.123456789+01:00"
        ),
    ])
    func capacityAndFormatSync(strategy: Strategy, offset: Int?, expectedCap: Int, expectedStr: String) {
        let formatter = ChronoFormatter(strategy: strategy)

        // Check capacity calculation
        let capacity = formatter.bufferCapacity(offset: offset)
        #expect(capacity == expectedCap, "Capacity mismatch for strategy \(strategy)")

        // Check raw buffer formatting
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: capacity, alignment: 1)
        defer { buffer.deallocate() }

        let written = formatter.format(date: testDate, time: testTime, offset: offset, to: buffer)

        #expect(written == capacity, "Bytes written should match calculated capacity")
        let result = String(decoding: buffer[..<written], as: UTF8.self)
        #expect(result == expectedStr)
    }

    @Test("ISO8601 Zulu vs Offset Logic")
    func iso8601ZuluLogic() {
        let formatter = ChronoFormatter.iso8601(digits: 0, includeOffset: true, useZulu: true)

        // UTC should be 'Z' (1 byte)
        #expect(formatter.bufferCapacity(offset: 0) == 20)
        #expect(formatter.string(date: testDate, time: testTime, offset: 0).hasSuffix("Z"))

        // Non-UTC should be '+HH:MM' (6 bytes)
        #expect(formatter.bufferCapacity(offset: -18000) == 25)
        #expect(formatter.string(date: testDate, time: testTime, offset: -18000).hasSuffix("-05:00"))
    }

    @Test("Fractional digits boundary (0 to 9)")
    func fractionalDigits() {
        // Test no dot when digits is 0
        let noDigits = ChronoFormatter.dateTimeSpace(digits: 0)
        #expect(noDigits.bufferCapacity() == 19)
        #expect(!noDigits.string(date: testDate, time: testTime).contains("."))

        // Test dot + 9 digits
        let maxDigits = ChronoFormatter.dateTimeSpace(digits: 9)
        #expect(maxDigits.bufferCapacity() == 19 + 1 + 9)
        #expect(maxDigits.string(date: testDate, time: testTime).hasSuffix(".123456789"))
    }
}
