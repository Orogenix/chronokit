@testable import ChronoTZ
import Testing

struct BinaryReaderTests {
    @Test("BinaryReaderTests: Initialization and remaining bytes")
    func initialization() throws {
        let data: [UInt8] = [0x01, 0x02, 0x03]
        try withReader(bytes: data) { reader in
            #expect(reader.capacity == 3)
            #expect(reader.remainingBytes == 3)
        }
    }

    @Test("BinaryReaderTests: Read single byte")
    func testReadByte() throws {
        let data: [UInt8] = [0xAA, 0xBB]
        try withReader(bytes: data) { reader in
            let byte1 = try reader.readByte()
            #expect(byte1 == 0xAA)
            #expect(reader.remainingBytes == 1)

            let byte2 = try reader.readByte()
            #expect(byte2 == 0xBB)
            #expect(reader.remainingBytes == 0)
        }
    }

    @Test("BinaryReaderTests: Read generic types (Unaligned)")
    func readGeneric() throws {
        let data: [UInt8] = [0x01, 0x00, 0x00, 0x00] // UInt32(1) in Little Endian
        try withReader(bytes: data) { reader in
            let value = try reader.read(UInt32.self)
            #expect(value == 1)
        }
    }

    @Test("BinaryReaderTests: Read Big Endian integers")
    func testReadBigEndian() throws {
        // 0x01020304 as Big Endian
        let data: [UInt8] = [0x01, 0x02, 0x03, 0x04]
        try withReader(bytes: data) { reader in
            let value = try reader.readBigEndian(UInt32.self)
            #expect(value == 0x0102_0304)
        }
    }

    @Test("BinaryReaderTests: Read string")
    func testReadString() throws {
        let data = Array("Hello".utf8)
        try withReader(bytes: data) { reader in
            let str = try reader.readString(length: 5)
            #expect(str == "Hello")
        }
    }

    @Test("BinaryReaderTests: Skip bytes")
    func testSkip() throws {
        let data: [UInt8] = [0x01, 0x02, 0x03, 0x04]
        try withReader(bytes: data) { reader in
            try reader.skip(bytes: 2)
            #expect(reader.remainingBytes == 2)
            let value = try reader.readByte()
            #expect(value == 0x03)
        }
    }

    @Test("BinaryReaderTests: Premature EOF throws error")
    func eof() throws {
        let data: [UInt8] = [0x01]
        try withReader(bytes: data) { reader in
            // Try to read 2 bytes from a 1-byte buffer
            #expect(throws: CodecError.prematureEOF) {
                _ = try reader.read(UInt16.self)
            }
        }
    }
}

// MARK: - Helpers

extension BinaryReaderTests {
    private func withReader(
        bytes: [UInt8],
        body: (inout BinaryReader) throws -> Void
    ) throws {
        try bytes.withUnsafeBytes { buffer in
            let ptr = try #require(buffer.baseAddress)
            var reader = BinaryReader(ptr: ptr, capacity: buffer.count)
            try body(&reader)
        }
    }
}
