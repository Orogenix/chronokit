@testable import ChronoTZ
import Testing

struct FixedMagicTests {
    @Test("FixedMagicTests: Initialization from bytes")
    func initialization() {
        let bytes: [UInt8] = [0x54, 0x5A, 0x44, 0x42]
        let magic = FixedMagic(bytes: bytes)

        // Verify via Equatable against a known good value
        #expect(magic == FixedMagic.tzdb)
    }

    @Test("FixedMagicTests: Initialization with exact 4 bytes")
    func initExact() {
        let input = [UInt8](repeating: 0xAB, count: 4)
        let name = FixedMagic(bytes: input)
        #expect(name.bytes == input)
    }

    @Test("FixedMagicTests: Handles short byte arrays gracefully")
    func shortInitialization() {
        // Test that it doesn't crash or overflow with < 4 bytes
        let shortBytes: [UInt8] = [0x54, 0x5A]
        let magic = FixedMagic(bytes: shortBytes)

        // Verify it didn't crash and filled the rest with zeros (from initializer)
        #expect(magic != FixedMagic.tzdb)
    }

    @Test("FixedMagicTests: Constants match expected signature")
    func constants() {
        // Explicitly check that the 'tzdb' magic is correct
        let magic = FixedMagic.tzdb

        // Convert to array to inspect
        let bytes = withUnsafeBytes(of: magic.data) { Array($0) }

        #expect(bytes == [0x54, 0x5A, 0x44, 0x42])
    }

    @Test("FixedMagicTests: Hashable implementation consistency")
    func hashable() {
        let magic1 = FixedMagic.tzdb
        let magic2 = FixedMagic(bytes: [0x54, 0x5A, 0x44, 0x42])

        #expect(magic1.hashValue == magic2.hashValue)
    }
}

package extension FixedMagic {
    var bytes: [UInt8] {
        withUnsafeBytes(of: data) { buffer in
            Array(buffer)
        }
    }
}
