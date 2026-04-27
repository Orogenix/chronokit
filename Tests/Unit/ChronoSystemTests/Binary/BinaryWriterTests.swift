@testable import ChronoSystem
import Testing

struct BinaryWriterTests {
    @Test("BinaryWriterTests: Write single byte")
    func testWriteByte() throws {
        let buffer = try withWriter(capacity: 2) { writer in
            try writer.writeByte(0xAA)
            try writer.writeByte(0xBB)
        }
        #expect(buffer == [0xAA, 0xBB])
    }

    @Test("BinaryWriterTests: Write multiple bytes")
    func testWriteBytes() throws {
        let buffer = try withWriter(capacity: 3) { writer in
            try writer.writeBytes([0x01, 0x02, 0x03])
        }
        #expect(buffer == [0x01, 0x02, 0x03])
    }

    @Test("BinaryWriterTests: Write Big Endian integer")
    func testWriteBigEndian() throws {
        // UInt32(0x01020304) -> [0x01, 0x02, 0x03, 0x04]
        let buffer = try withWriter(capacity: 4) { writer in
            try writer.writeBigEndian(UInt32(0x0102_0304))
        }
        #expect(buffer == [0x01, 0x02, 0x03, 0x04])
    }

    @Test("BinaryWriterTests: Buffer overflow throws error")
    func testBufferOverflow() throws {
        // Capacity 2, trying to write 3 bytes
        _ = try withWriter(capacity: 2) { writer in
            #expect(throws: BinaryError.bufferOverflow) {
                try writer.writeBytes([0x01, 0x02, 0x03])
            }
        }
    }

    @Test("BinaryWriterTests: WriteBigEndian overflow throws error")
    func writeBigEndianOverflow() throws {
        // Capacity 2, trying to write UInt32 (4 bytes)
        _ = try withWriter(capacity: 2) { writer in
            #expect(throws: BinaryError.bufferOverflow) {
                try writer.writeBigEndian(UInt32(0x01))
            }
        }
    }
}

// MARK: - Helpers

extension BinaryWriterTests {
    private func withWriter(
        capacity: Int,
        body: (inout BinaryWriter) throws -> Void
    ) throws -> [UInt8] {
        var data = [UInt8](repeating: 0, count: capacity)
        try data.withUnsafeMutableBytes { buffer in
            var writer = BinaryWriter(ptr: buffer.baseAddress!, capacity: capacity)
            try body(&writer)
        }
        return data
    }
}
