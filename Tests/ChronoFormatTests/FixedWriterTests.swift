@testable import ChronoFormat
import Testing

@Suite("FixedWriter Performance & Correctness")
struct FixedWriterTests {
    // MARK: - Fixed Digit Write Tests

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

        FixedWriter.write2(value, to: buffer, at: 0)
        let result = String(decoding: buffer.prefix(2), as: UTF8.self)
        #expect(result == expected)
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

        FixedWriter.write4(value, to: buffer, at: 0)
        let result = String(decoding: buffer.prefix(4), as: UTF8.self)
        #expect(result == expected)
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

        buffer.initializeMemory(as: UInt8.self, repeating: 0)

        FixedWriter.writeFraction(nano, digits: digits, to: buffer, at: 0)
        let result = String(decoding: buffer.prefix(digits), as: UTF8.self)
        #expect(result == expected)
    }

    @Test("FixedWriterTests: Fraction out-of-bounds safety")
    func invalidDigits() {
        let nano: Int64 = 123_456_789
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 9, alignment: 1)
        defer { buffer.deallocate() }

        FixedWriter.writeFraction(nano, digits: 0, to: buffer, at: 0)
        FixedWriter.writeFraction(nano, digits: 10, to: buffer, at: 0)

        #expect(Bool(true), "Did not crash on invalid input")
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

        FixedWriter.writeOffset(seconds, to: buffer, at: 0)
        let result = String(decoding: buffer.prefix(6), as: UTF8.self)
        #expect(result == expected)
    }
}

// MARK: - Character Write Tests

extension FixedWriterTests {
    @Test("FixedWriterTests: Write single character at various offsets")
    func writeCharAtOffsets() {
        // Allocate a small buffer
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 5, alignment: 1)
        defer { buffer.deallocate() }
        buffer.initializeMemory(as: UInt8.self, repeating: 0)

        // Write 'A' at offset 0
        let written1 = FixedWriter.writeChar(65, to: buffer, at: 0) // 65 is 'A'
        #expect(written1 == 1)
        #expect(buffer[0] == 65)

        // Write 'B' at offset 2
        let written2 = FixedWriter.writeChar(66, to: buffer, at: 2) // 66 is 'B'
        #expect(written2 == 1)
        #expect(buffer[2] == 66)

        // Check intervening byte is still 0
        #expect(buffer[1] == 0)
    }

    @Test("FixedWriterTests: Writing outside buffer")
    func boundsSafety() {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 1, alignment: 1)
        defer { buffer.deallocate() }

        // Write at an invalid offset
        let written = FixedWriter.writeChar(65, to: buffer, at: 1)

        // If you added the 'guard' check I suggested, this should return 0
        // If not, this test would likely crash (which is also a result)
        #expect(written == 0)
    }

    @Test("FixedWriterTests: Sequential writing with a cursor")
    func cursorSequence() {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 3, alignment: 1)
        defer { buffer.deallocate() }

        var cursor = 0
        cursor += FixedWriter.writeChar(72, to: buffer, at: cursor) // 'H'
        cursor += FixedWriter.writeChar(73, to: buffer, at: cursor) // 'I'
        cursor += FixedWriter.writeChar(33, to: buffer, at: cursor) // '!'

        #expect(cursor == 3)
        #expect(buffer[0] == 72)
        #expect(buffer[1] == 73)
        #expect(buffer[2] == 33)
    }
}

// MARK: - Safety & Buffer Bounds Tests

extension FixedWriterTests {
    @Test("FixedWriterTests: Buffer overflow safety")
    func safety() {
        let tinyBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 1, alignment: 1)
        defer { tinyBuffer.deallocate() }

        // These should return silently due to your guard statements
        FixedWriter.write2(10, to: tinyBuffer, at: 0)
        FixedWriter.write4(2025, to: tinyBuffer, at: 0)
        FixedWriter.writeOffset(3600, to: tinyBuffer, at: 0)

        #expect(Bool(true), "Completed without crashing")
    }
}
