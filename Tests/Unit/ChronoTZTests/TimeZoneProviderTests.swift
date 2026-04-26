import ChronoCore
@testable import ChronoTZ
import Foundation
import Testing

struct TimeZoneProviderTests {
    @Test("TimeZoneProviderTests: Initializes and retrieves zone")
    func initializationAndRetrieval() throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tz_provider_test.tzdb")
        defer { try? FileManager.default.removeItem(at: tempURL) }
        try createMockDB(at: tempURL.path, entryName: "UTC")

        let provider = try IANAProvider(path: tempURL.path)
        let zone = try provider.getTimeZone(named: "UTC")

        #expect(zone.identifier == "UTC")
    }

    @Test("TimeZoneProviderTests: Caches objects (same instance returned)")
    func cacheIdentity() throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tz_provider_test_cache.tzdb")
        defer { try? FileManager.default.removeItem(at: tempURL) }
        try createMockDB(at: tempURL.path, entryName: "UTC")

        let provider = try IANAProvider(path: tempURL.path)

        let firstCall = try provider.getTimeZone(named: "UTC")
        let secondCall = try provider.getTimeZone(named: "UTC")

        #expect(firstCall == secondCall, "Provider should return the cached instance")
    }

    @Test("TimeZoneProviderTests: Throws error for missing zone")
    func missingZoneThrows() throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tz_provider_missing.tzdb")
        defer { try? FileManager.default.removeItem(at: tempURL) }
        try createMockDB(at: tempURL.path, entryName: "UTC")

        let provider = try IANAProvider(path: tempURL.path)

        #expect(throws: TimeZoneError.zoneNotFound("NonExistent")) {
            try provider.getTimeZone(named: "NonExistent")
        }
    }

    @Test("TimeZoneProviderTests: Concurrent access is thread-safe")
    func concurrentAccess() async throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tz_provider_concurrent.tzdb")
        defer { try? FileManager.default.removeItem(at: tempURL) }
        try createMockDB(at: tempURL.path, entryName: "UTC")

        let provider = try IANAProvider(path: tempURL.path)

        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 10 {
                group.addTask {
                    _ = try? provider.getTimeZone(named: "UTC")
                }
            }
        }
    }
}

// MARK: - Helpers

extension TimeZoneProviderTests {
    private func createMockDB(
        at path: String,
        entryName: String
    ) throws {
        // Serialize the payload
        let types = [TypeDefinition(offset: 0, isDST: 0)]
        let transitions = [Transition(unixTime: 0, typeIndex: 0)]
        let validPayload = TZDataPayload(
            transitionCount: 1,
            typeCount: 1,
            transitions: transitions,
            types: types,
            posixRule: nil
        )
        let payloadData = try TZDBCodec.encode(validPayload)

        // Manual Binary Construction
        var data = Data()

        // --- Write Header ---
        // Magic: TZDB (4 bytes)
        data.append(contentsOf: [0x54, 0x5A, 0x44, 0x42])
        // Version: 1 (Big Endian)
        data.append(contentsOf: withUnsafeBytes(of: UInt32(1).bigEndian) { Array($0) })
        // Count: 1 (Big Endian)
        data.append(contentsOf: withUnsafeBytes(of: UInt32(1).bigEndian) { Array($0) })

        // --- Write Index Entry ---
        // Name: FixedName (64 bytes total)
        var nameBytes = Array(entryName.utf8)
        // Pad with zeros to 64 bytes
        nameBytes.append(contentsOf: Array(repeating: UInt8(0), count: FixedName.size - nameBytes.count))
        data.append(contentsOf: nameBytes)

        // Offset: 4 bytes (Big Endian)
        // Header(12) + Entry(72) = 84 bytes offset
        data.append(contentsOf: withUnsafeBytes(of: UInt32(84).bigEndian) { Array($0) })

        // Size: 4 bytes (Big Endian)
        data.append(contentsOf: withUnsafeBytes(of: UInt32(payloadData.count).bigEndian) { Array($0) })

        // --- Write Payload ---
        data.append(contentsOf: payloadData)

        try data.write(to: URL(fileURLWithPath: path))
    }
}
