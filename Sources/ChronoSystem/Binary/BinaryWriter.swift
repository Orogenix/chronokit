package struct BinaryWriter {
    private let ptr: UnsafeMutableRawPointer
    private var offset: Int = 0
    package let capacity: Int

    package init(
        ptr: UnsafeMutableRawPointer,
        capacity: Int
    ) {
        self.ptr = ptr
        self.capacity = capacity
    }
}

package extension BinaryWriter {
    mutating func writeByte(_ byte: UInt8) throws(BinaryError) {
        guard offset + 1 <= capacity else { throw .bufferOverflow }
        ptr.storeBytes(of: byte, toByteOffset: offset, as: UInt8.self)
        offset += 1
    }

    mutating func writeBytes(_ bytes: [UInt8]) throws(BinaryError) {
        let count = bytes.count
        guard offset + count <= capacity else { throw BinaryError.bufferOverflow }

        do {
            try bytes.withUnsafeBytes { buffer in
                guard let sourcePtr = buffer.baseAddress else {
                    throw BinaryError.memoryAccessFailed
                }
                ptr.advanced(by: offset).copyMemory(from: sourcePtr, byteCount: count)
            }
        } catch let error as BinaryError {
            throw error
        } catch {
            throw .memoryAccessFailed
        }

        offset += count
    }

    mutating func writeBigEndian<T: FixedWidthInteger>(_ value: T) throws(BinaryError) {
        let size = MemoryLayout<T>.size
        guard offset + size <= capacity else { throw .bufferOverflow }
        let val = value.bigEndian
        ptr.storeBytes(of: val, toByteOffset: offset, as: T.self)
        offset += size
    }
}
