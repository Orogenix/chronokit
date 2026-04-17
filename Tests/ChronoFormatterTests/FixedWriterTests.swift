@testable import ChronoFormatter
import ChronoMath
import Testing

// MARK: - Fixed Digit Write Tests

struct FixedWriterTests {
    @Test("FixedWriterTests: Writing 2-digit integers (including overflow)", arguments: [
        (25, "25"),
        (0, "00"),
        (9, "09"),
        (99, "99"),
        (123, "23"), // Overflow: should truncate to last 2 digits
        (100, "00"), // Edge: should result in 00
    ])
    func testWrite2(value: Int, expected: String) {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 2, alignment: 1)
        defer { buffer.deallocate() }

        var cursor = 0
        FixedWriter.write2(value, to: buffer, at: &cursor)

        let result = String(decoding: buffer.prefix(2), as: UTF8.self)
        #expect(result == expected)
        #expect(cursor == 2)
    }

    @Test("FixedWriterTests: Writing 4-digit years (including overflow)", arguments: [
        (2025, "2025"),
        (1, "0001"),
        (9999, "9999"),
        (0, "0000"),
        (12345, "2345"), // Overflow: should truncate to last 4 digits
        (10000, "0000") // Edge: should result in 0000
    ])
    func testWrite4(value: Int, expected: String) {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 4, alignment: 1)
        defer { buffer.deallocate() }

        var cursor = 0
        FixedWriter.write4(value, to: buffer, at: &cursor)

        let result = String(decoding: buffer.prefix(4), as: UTF8.self)
        #expect(result == expected)
        #expect(cursor == 4)
    }
}

// MARK: - Fractions Write Tests

extension FixedWriterTests {
    @Test("FixedWriterTests: Writing fractions with varying precision", arguments: [
        (1, "1"),
        (2, "12"),
        (3, "123"),
        (4, "1234"),
        (5, "12345"),
        (6, "123456"),
        (7, "1234567"),
        (8, "12345678"),
        (9, "123456789"),
    ])
    func testWriteFraction(digits: Int, expected: String) {
        let nano: Int64 = 123_456_789
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: digits, alignment: 1)
        defer { buffer.deallocate() }

        var cursor = 0
        FixedWriter.writeFraction(nano, digits: digits, to: buffer, at: &cursor)

        let result = String(decoding: buffer.prefix(digits), as: UTF8.self)
        #expect(result == expected)
        #expect(cursor == digits)
    }

    @Test("FixedWriterTests: Fraction out-of-bounds safety")
    func invalidDigits() {
        let nano: Int64 = 123_456_789
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 9, alignment: 1)
        defer { buffer.deallocate() }

        var cursor = 0
        FixedWriter.writeFraction(nano, digits: 0, to: buffer, at: &cursor)
        #expect(cursor == 0)

        FixedWriter.writeFraction(nano, digits: 10, to: buffer, at: &cursor)
        #expect(cursor == 0)
    }
}

// MARK: - TimeZone Offsets Write Tests

extension FixedWriterTests {
    @Test("FixedWriterTests: Writing TimeZone offsets", arguments: [
        (0, "+00:00"),
        (3600, "+01:00"),
        (-18000, "-05:00"),
        (34200, "+09:30"), // Half-hour offset
        (-50400, "-14:00"), // Max ISO offset
    ])
    func testWriteOffset(seconds: Int, expected: String) {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 6, alignment: 1)
        defer { buffer.deallocate() }

        var cursor = 0
        FixedWriter.writeOffset(seconds, to: buffer, at: &cursor)

        let digits = 6
        let result = String(decoding: buffer.prefix(digits), as: UTF8.self)
        #expect(result == expected)
        #expect(cursor == digits)
    }
}

// MARK: - Byte Write Tests

extension FixedWriterTests {
    @Test("FixedWriterTests: Write single character at various offsets")
    func writeByteAtOffsets() {
        // Allocate a small buffer
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 5, alignment: 1)
        defer { buffer.deallocate() }

        var cursor = 0
        FixedWriter.writeByte(ASCII.charA, to: buffer, at: &cursor)
        #expect(cursor == 1)
        #expect(buffer[0] == ASCII.charA, "Should write 'A' at offset 0")

        cursor = 2
        FixedWriter.writeByte(ASCII.charB, to: buffer, at: &cursor)
        #expect(cursor == 3)
        #expect(buffer[2] == ASCII.charB, "Should write 'B' at offset 2")
        #expect(buffer[1] == 0, "Intervening byte should stay 0")
    }

    @Test("FixedWriterTests: Sequential writing with a cursor")
    func cursorSequence() {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 3, alignment: 1)
        defer { buffer.deallocate() }

        var cursor = 0
        FixedWriter.writeByte(ASCII.charH, to: buffer, at: &cursor)
        FixedWriter.writeByte(ASCII.charI, to: buffer, at: &cursor)
        FixedWriter.writeByte(ASCII.bang, to: buffer, at: &cursor)

        #expect(cursor == 3)
        #expect(buffer[0] == ASCII.charH)
        #expect(buffer[1] == ASCII.charI)
        #expect(buffer[2] == ASCII.bang)
    }
}

// MARK: - Safety & Buffer Bounds Tests

extension FixedWriterTests {
    @Test("FixedWriterTests: Buffer overflow safety")
    func safety() {
        let tinyBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 1, alignment: 1)
        defer { tinyBuffer.deallocate() }

        var cursor = 0

        // These should return silently due to your guard statements
        FixedWriter.write2(10, to: tinyBuffer, at: &cursor)
        #expect(cursor == 0)

        FixedWriter.write4(2025, to: tinyBuffer, at: &cursor)
        #expect(cursor == 0)

        FixedWriter.writeOffset(3600, to: tinyBuffer, at: &cursor)
        #expect(cursor == 0)

        // writeByte fits in exactly 1 byte
        FixedWriter.writeByte(65, to: tinyBuffer, at: &cursor)
        #expect(cursor == 1)

        // This should fail now as cursor is at 1 and capacity is 1
        FixedWriter.writeByte(66, to: tinyBuffer, at: &cursor)
        #expect(cursor == 1)
    }
}
