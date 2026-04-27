@frozen
package struct FixedMagic {
    package static let size: Int = 4

    // swiftlint:disable:next large_tuple
    package let data: (UInt8, UInt8, UInt8, UInt8)

    package init() {
        data = (0, 0, 0, 0)
    }

    package init(
        bytes: [UInt8]
    ) {
        var data = (UInt8(0), UInt8(0), UInt8(0), UInt8(0))

        withUnsafeMutableBytes(of: &data) { ptr in
            let count = min(bytes.count, Self.size)
            ptr.copyBytes(from: bytes.prefix(count))
        }

        self.data = data
    }
}

package extension FixedMagic {
    static let tzdb = Self(bytes: [0x54, 0x5A, 0x44, 0x42])
}

extension FixedMagic: Equatable {
    package static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.data == rhs.data
    }
}

extension FixedMagic: Hashable {
    package func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: data) { buffer in
            hasher.combine(bytes: buffer)
        }
    }
}
