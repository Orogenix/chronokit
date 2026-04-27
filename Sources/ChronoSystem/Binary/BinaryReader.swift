package struct BinaryReader {
    private let ptr: UnsafeRawPointer
    package var offset: Int = 0
    package let capacity: Int

    package init(
        ptr: UnsafeRawPointer,
        capacity: Int
    ) {
        self.ptr = ptr
        self.capacity = capacity
    }
}

package extension BinaryReader {
    var remainingBytes: Int {
        capacity - offset
    }

    mutating func readBytes(count: Int) throws(BinaryError) -> [UInt8] {
        guard offset + count <= capacity else { throw .prematureEOF }

        let start = ptr.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: start, count: count)
        let bytes = Array(buffer)

        offset += count
        return bytes
    }

    mutating func readByte() throws(BinaryError) -> UInt8 {
        guard offset + 1 <= capacity else { throw .prematureEOF }
        let value = ptr.load(fromByteOffset: offset, as: UInt8.self)
        offset += 1
        return value
    }

    mutating func read<T>(_: T.Type) throws(BinaryError) -> T {
        let size = MemoryLayout<T>.size
        guard offset + size <= capacity else { throw .prematureEOF }
        let value = ptr.loadUnaligned(fromByteOffset: offset, as: T.self)
        offset += size
        return value
    }

    mutating func readBigEndian<T: FixedWidthInteger>(_: T.Type) throws(BinaryError) -> T {
        let value = try read(T.self)
        return T(bigEndian: value)
    }

    mutating func readString(length: Int) throws(BinaryError) -> String {
        guard offset + length <= capacity else { throw .prematureEOF }
        let start = ptr.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: start, count: length)
        let value = String(decoding: buffer, as: UTF8.self)
        offset += length
        return value
    }

    mutating func readString(length: UInt32) throws(BinaryError) -> String {
        try readString(length: Int(length))
    }

    func peekBytes(count: Int) throws(BinaryError) -> [UInt8] {
        guard offset + count <= capacity else { throw .prematureEOF }
        let start = ptr.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: start, count: count)
        return Array(buffer)
    }

    mutating func skip(bytes: Int) throws(BinaryError) {
        guard offset + bytes <= capacity else { throw .prematureEOF }
        offset += bytes
    }

    mutating func skipUntil(
        bytes: [UInt8]
    ) throws(BinaryError) -> Bool {
        let count = bytes.count

        while remainingBytes >= count {
            let next = try peekBytes(count: count)
            if next == bytes {
                return true
            }
            try skip(bytes: 1)
        }

        return false
    }
}
