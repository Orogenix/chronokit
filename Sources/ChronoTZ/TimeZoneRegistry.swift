import ChronoSystem

struct TimeZoneRegistry {
    private let file: MappedFile
    private let header: TZDBHeader
    private let indexEntries: [TZDBIndexEntry]
}

extension TimeZoneRegistry {
    var indexNames: [String] {
        indexEntries.map(\.nameString)
    }
}

extension TimeZoneRegistry {
    init(path: String) throws {
        file = try MappedFile(path: path)

        let ptr = try file.getPointer()
        var reader = BinaryReader(ptr: ptr, capacity: file.size)

        // Header
        let magic = try reader.readBytes(count: TZDBHeader.ianaMagicSize)
        let version = try reader.readBigEndian(UInt32.self)
        let count = try reader.readBigEndian(UInt32.self)
        let header = TZDBHeader(magic: magic, version: version, count: count)
        guard header.magic == .tzdb else { throw TZDBError.invalidHeader }
        self.header = header

        // Index Entry
        var tempIndexEntries: [TZDBIndexEntry] = []
        tempIndexEntries.reserveCapacity(Int(header.count))
        for _ in 0 ..< Int(header.count) {
            let name = try reader.readBytes(count: TZDBIndexEntry.nameSize)
            let offset = try reader.readBigEndian(UInt32.self)
            let size = try reader.readBigEndian(UInt32.self)
            let entry = TZDBIndexEntry(name: name, offset: offset, size: size)
            tempIndexEntries.append(entry)
        }

        indexEntries = tempIndexEntries
    }

    func getEntry(named name: String) -> TZDBIndexEntry? {
        return indexEntries.first {
            $0.nameString == name
        }
    }

    func getPayload(for entry: TZDBIndexEntry) throws -> UnsafeRawBufferPointer {
        return try file.buffer(at: Int(entry.offset), size: Int(entry.size))
    }
}
