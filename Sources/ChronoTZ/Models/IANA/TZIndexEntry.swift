package struct TZIndexEntry: Equatable, Hashable {
    package var name: FixedName
    package var offset: UInt32
    package var size: UInt32

    package init(
        name: [UInt8],
        offset: UInt32,
        size: UInt32
    ) {
        self.name = FixedName(bytes: name)
        self.offset = offset
        self.size = size
    }

    package init(
        name: String,
        offset: UInt32,
        size: UInt32
    ) {
        self.name = FixedName(bytes: Array(name.utf8))
        self.offset = offset
        self.size = size
    }
}

package extension TZIndexEntry {
    static let nameSize: Int = FixedName.size
    static let fixedSize: Int = nameSize + 4 + 4
}

extension TZIndexEntry {
    var nameString: String {
        withUnsafeBytes(of: name) { buffer in
            // Treat the memory as a sequence of UInt8
            let bytes = buffer.bindMemory(to: UInt8.self)
            // Find the length to the first null terminator (\0 is 0)
            // If no null terminator, use the full count
            let length = bytes.firstIndex(of: 0) ?? bytes.count

            return String(decoding: bytes.prefix(length), as: UTF8.self)
        }
    }
}
