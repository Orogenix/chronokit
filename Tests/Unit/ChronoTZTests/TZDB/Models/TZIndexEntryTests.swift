@testable import ChronoTZ
import Testing

struct TZIndexEntryTests {
    @Test("TZIndexEntryTests: Initialization from String maps correctly")
    func initFromString() {
        let name = "UTC"
        let offset: UInt32 = 0
        let size: UInt32 = 128

        let entry = TZIndexEntry(name: name, offset: offset, size: size)

        #expect(entry.nameString == name)
        #expect(entry.offset == offset)
        #expect(entry.size == size)
    }

    @Test("TZIndexEntryTests: nameString correctly handles null-terminated strings")
    func nameStringNullTermination() {
        // Create an entry where the string is shorter than the fixed size
        // The rest of the FixedName will be 0s, which act as null terminators
        let name = "GMT"
        let entry = TZIndexEntry(name: name, offset: 0, size: 0)
        #expect(entry.nameString == "GMT")
    }

    @Test("TZIndexEntryTests: nameString handles full 64-byte capacity")
    func nameStringFullCapacity() {
        // Create a string that is exactly 64 bytes long
        let longName = String(repeating: "A", count: 64)
        let entry = TZIndexEntry(name: longName, offset: 0, size: 0)

        #expect(entry.nameString == longName)
        #expect(entry.nameString.count == 64)
    }

    @Test("TZIndexEntryTests: Equatable conformance")
    func equatable() {
        let entry1 = TZIndexEntry(name: "Europe/London", offset: 3600, size: 1024)
        let entry2 = TZIndexEntry(name: "Europe/London", offset: 3600, size: 1024)
        let entry3 = TZIndexEntry(name: "America/New_York", offset: 5000, size: 1024)

        #expect(entry1 == entry2)
        #expect(entry1 != entry3)
    }

    @Test("TZIndexEntryTests: Metadata constants")
    func constants() {
        #expect(TZIndexEntry.nameSize == 64)
        #expect(TZIndexEntry.fixedSize == 72) // 64 (name) + 4 (offset) + 4 (size)
    }
}
