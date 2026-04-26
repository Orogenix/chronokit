@testable import ChronoTZ
import Testing

struct IANACodecTests {
    @Test("IANACodecTests: Invalid header throws error")
    func testInvalidHeader() throws {
        let invalidData: [UInt8] = [0x00, 0x00, 0x00, 0x00]
        #expect(throws: CodecError.invalidHeader) {
            _ = try IANACodec.decode(from: invalidData)
        }
    }

    @Test("IANACodecTests: Valid payload decoding")
    func decodeSuccess() throws {
        let data = try createMockTZif()
        let payload = try IANACodec.decode(from: data)

        #expect(payload.transitionCount == 1)
        #expect(payload.typeCount == 1)
        #expect(payload.transitions.first?.unixTime == 1_777_636_800)
        #expect(payload.types.first?.offset == 3600)
        #expect(payload.posixRule == "UTC0")
    }
}

extension IANACodecTests {
    private func createMockTZif() throws -> [UInt8] {
        var data = [UInt8](repeating: 0, count: 109)
        try data.withUnsafeMutableBytes { buffer in
            var writer = BinaryWriter(ptr: buffer.baseAddress!, capacity: buffer.count)

            // --- V1 Header ---
            try writer.writeBytes([0x54, 0x5A, 0x69, 0x66, 0x31]) // "TZif1"
            try writer.writeBytes([UInt8](repeating: 0, count: 15)) // Reserved
            // 6 counts for V1 (all 0 for minimal test)
            for _ in 0 ..< 6 {
                try writer.writeBigEndian(Int32(0))
            }

            // --- V2 Header ---
            try writer.writeBytes([0x54, 0x5A, 0x69, 0x66, 0x32]) // "TZif2"
            try writer.writeBytes([UInt8](repeating: 0, count: 15)) // Reserved

            try writer.writeBigEndian(Int32(0)) // ttisutcnt
            try writer.writeBigEndian(Int32(0)) // ttisstdcnt
            try writer.writeBigEndian(Int32(0)) // leapcnt
            try writer.writeBigEndian(Int32(1)) // timeCount (1 Transition)
            try writer.writeBigEndian(Int32(1)) // typeCount (1 Type)
            try writer.writeBigEndian(Int32(0)) // charcnt

            // --- Transition ---
            try writer.writeBigEndian(Int64(1_777_636_800)) // 2026-06-01
            try writer.writeByte(0) // typeIndex

            // --- Type Definition ---
            try writer.writeBigEndian(Int32(3600)) // offset (1 hour)
            try writer.writeByte(0) // isDST
            try writer.writeByte(0) // abbrind

            // ---POSIX Rule ---
            try writer.writeBytes(Array("\nUTC0\n".utf8))
        }

        return data
    }
}
