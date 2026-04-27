struct BinaryReader {
    private let ptr: UnsafeRawPointer
    var offset: Int = 0
    let capacity: Int

    init(
        ptr: UnsafeRawPointer,
        capacity: Int
    ) {
        self.ptr = ptr
        self.capacity = capacity
    }
}

extension BinaryReader {
    var remainingBytes: Int {
        capacity - offset
    }

    mutating func readBytes(count: Int) throws(CodecError) -> [UInt8] {
        guard offset + count <= capacity else { throw .prematureEOF }

        let start = ptr.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: start, count: count)
        let bytes = Array(buffer)

        offset += count
        return bytes
    }

    mutating func readByte() throws(CodecError) -> UInt8 {
        guard offset + 1 <= capacity else { throw .prematureEOF }
        let value = ptr.load(fromByteOffset: offset, as: UInt8.self)
        offset += 1
        return value
    }

    mutating func read<T>(_: T.Type) throws(CodecError) -> T {
        let size = MemoryLayout<T>.size
        guard offset + size <= capacity else { throw .prematureEOF }
        let value = ptr.loadUnaligned(fromByteOffset: offset, as: T.self)
        offset += size
        return value
    }

    mutating func readBigEndian<T: FixedWidthInteger>(_: T.Type) throws(CodecError) -> T {
        let value = try read(T.self)
        return T(bigEndian: value)
    }

    mutating func readString(length: Int) throws(CodecError) -> String {
        guard offset + length <= capacity else { throw .prematureEOF }
        let start = ptr.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: start, count: length)
        let value = String(decoding: buffer, as: UTF8.self)
        offset += length
        return value
    }

    mutating func readString(length: UInt32) throws(CodecError) -> String {
        try readString(length: Int(length))
    }

    func peekBytes(count: Int) throws(CodecError) -> [UInt8] {
        guard offset + count <= capacity else { throw .prematureEOF }
        let start = ptr.advanced(by: offset).assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: start, count: count)
        return Array(buffer)
    }

    mutating func skip(bytes: Int) throws(CodecError) {
        guard offset + bytes <= capacity else { throw .prematureEOF }
        offset += bytes
    }

    mutating func skipUntil(
        bytes: [UInt8],
        failed error: CodecError = .prematureEOF
    ) throws(CodecError) {
        let count = bytes.count

        while remainingBytes >= count {
            let next = try peekBytes(count: count)
            if next == bytes {
                return
            }
            try skip(bytes: 1)
        }

        throw error
    }
}
