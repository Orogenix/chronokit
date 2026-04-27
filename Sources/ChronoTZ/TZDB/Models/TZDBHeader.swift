package struct TZDBHeader: Equatable, Hashable {
    package var magic: FixedMagic
    package var version: UInt32
    package var count: UInt32

    package init(
        magic: FixedMagic,
        version: UInt32,
        count: UInt32
    ) {
        self.magic = magic
        self.version = version
        self.count = count
    }

    package init(
        magic: [UInt8],
        version: UInt32,
        count: UInt32
    ) {
        self.magic = FixedMagic(bytes: magic)
        self.version = version
        self.count = count
    }
}

package extension TZDBHeader {
    static let ianaMagicSize: Int = FixedMagic.size
    static let ianaVersionSize: Int = 4
    static let ianaCountSize: Int = 4
    static let ianaSize: Int = ianaMagicSize + ianaVersionSize + ianaCountSize

    static func iana(tableSize: Int) -> Self {
        Self(
            magic: .tzdb,
            version: UInt32(1).bigEndian,
            count: UInt32(tableSize).bigEndian
        )
    }
}
