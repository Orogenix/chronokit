@testable import ChronoSystem
@testable import ChronoTZ
import Foundation
import Testing

struct TimeZoneRegistryTests {
    @Test("TimeZoneRegistryTests: Fails on invalid magic")
    func invalidHeader() throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tz_registry_invalid.tzdb")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        // Write garbage data
        try Data("GARBAGE".utf8).write(to: tempURL)

        #expect(throws: BinaryError.prematureEOF) {
            _ = try TimeZoneRegistry(path: tempURL.path)
        }
    }

    @Test("TimeZoneRegistryTests: Successfully loads and retrieves entry")
    func successPath() throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tz_registry_test.tzdb")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let targetName = "UTC"
        let payload = "PAYLOAD_DATA_16B"
        try createMockTZDB(at: tempURL.path, entryName: targetName, payload: payload)

        let registry = try TimeZoneRegistry(path: tempURL.path)

        // Test getEntry
        let entry = try #require(registry.getEntry(named: targetName), "Should find the entry")
        #expect(entry.nameString == targetName)

        // Test getPayload
        let buffer = try registry.getPayload(for: entry)
        let ptr = UnsafeRawBufferPointer(start: buffer.baseAddress, count: buffer.count)
        let payloadString = String(decoding: ptr, as: UTF8.self)
        #expect(payloadString == payload)
    }
}

// MARK: - Helpers

extension TimeZoneRegistryTests {
    private func createMockTZDB(
        at path: String,
        entryName: String,
        payload: String
    ) throws {
        var data = Data()

        // ---- Write Header ----
        // Magic: TZDB (4 bytes)
        data.append(contentsOf: [0x54, 0x5A, 0x44, 0x42])
        // Version: 1 (4 bytes, BigEndian)
        data.append(contentsOf: withUnsafeBytes(of: UInt32(1).bigEndian) { Array($0) })
        // Count: 1 (4 bytes, BigEndian)
        data.append(contentsOf: withUnsafeBytes(of: UInt32(1).bigEndian) { Array($0) })

        // ---- Write Index Entry ----
        // Name: FixedName (64 bytes)
        var nameBytes = Array(entryName.utf8)
        nameBytes.append(contentsOf: Array(repeating: UInt8(0), count: FixedName.size - nameBytes.count))
        data.append(contentsOf: nameBytes)

        // Offset: 4 bytes, BigEndian
        // Header (12 bytes) + Entry (72 bytes) = 84 bytes offset
        data.append(contentsOf: withUnsafeBytes(of: UInt32(84).bigEndian) { Array($0) })
        // Size: 4 bytes, BigEndian
        data.append(contentsOf: withUnsafeBytes(of: UInt32(payload.utf8.count).bigEndian) { Array($0) })

        // ---- Write Payload ----
        data.append(contentsOf: payload.utf8)

        try data.write(to: URL(fileURLWithPath: path))
    }
}
