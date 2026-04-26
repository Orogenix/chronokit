@testable import ChronoTZ
import Testing

struct FixedNameTests {
    @Test("FixedNameTests: Initialization with exact 64 bytes")
    func initExact() {
        let input = [UInt8](repeating: 0xAB, count: 64)
        let name = FixedName(bytes: input)
        #expect(name.bytes == input)
    }

    @Test("FixedNameTests: Initialization truncates if over 64 bytes")
    func initTruncation() {
        let input = [UInt8](repeating: 0x01, count: 70)
        let name = FixedName(bytes: input)

        let expected = [UInt8](repeating: 0x01, count: 64)
        #expect(name.bytes == expected)
        #expect(name.bytes.count == 64)
    }

    @Test("FixedNameTests: Initialization pads with zeros if under 64 bytes")
    func initPadding() {
        let input: [UInt8] = [0x01, 0x02]
        let name = FixedName(bytes: input)

        var expected = [UInt8](repeating: 0, count: 64)
        expected[0] = 0x01
        expected[1] = 0x02

        #expect(name.bytes == expected)
    }

    @Test("FixedNameTests: Equatable conformance works with raw memory")
    func equatable() {
        let data1 = [UInt8](repeating: 0x41, count: 64)
        let data2 = [UInt8](repeating: 0x42, count: 64)

        let name1 = FixedName(bytes: data1)
        let name2 = FixedName(bytes: data1) // Same content
        let name3 = FixedName(bytes: data2) // Different content

        #expect(name1 == name2)
        #expect(name1 != name3)
    }

    @Test("FixedNameTests: Hashable conformance consistency")
    func hashable() {
        let input: [UInt8] = [0xAA, 0xBB, 0xCC]
        let name1 = FixedName(bytes: input)
        let name2 = FixedName(bytes: input)

        #expect(name1.hashValue == name2.hashValue)

        // Ensure different data produces different hashes
        let name3 = FixedName(bytes: [0x00, 0x00, 0x00])
        #expect(name1.hashValue != name3.hashValue)
    }
}

package extension FixedName {
    var bytes: [UInt8] {
        withUnsafeBytes(of: data) { buffer in
            Array(buffer)
        }
    }
}
