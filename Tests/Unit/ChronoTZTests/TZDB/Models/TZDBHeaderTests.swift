@testable import ChronoTZ
import Testing

struct TZDBHeaderTests {
    @Test("TZDBHeaderTests: IANA factory creates correct structure")
    func ianaFactory() {
        let tableSize = 50
        let header = TZDBHeader.iana(tableSize: tableSize)

        #expect(header.magic == FixedMagic.tzdb)
        // Ensure values are stored as BigEndian as per factory implementation
        #expect(header.version == UInt32(1).bigEndian)
        #expect(header.count == UInt32(tableSize).bigEndian)
    }

    @Test("TZDBHeaderTests: Equatable conformance works as expected")
    func equatable() {
        let h1 = TZDBHeader(magic: .tzdb, version: 1, count: 50)
        let h2 = TZDBHeader(magic: .tzdb, version: 1, count: 50)
        let h3 = TZDBHeader(magic: .tzdb, version: 2, count: 50)

        #expect(h1 == h2)
        #expect(h1 != h3)
    }
}

// MARK: - Helpers

extension TZDBHeaderTests {
    private func createValidBuffer(version: UInt32, count: UInt32) -> [UInt8] {
        let magic: [UInt8] = [0x54, 0x5A, 0x44, 0x42] // TZDB
        let versionBytes = version.bigEndian.toBytes()
        let countBytes = count.bigEndian.toBytes()
        return magic + versionBytes + countBytes
    }
}

extension FixedWidthInteger {
    func toBytes() -> [UInt8] {
        withUnsafeBytes(of: self) { Array($0) }
    }
}
