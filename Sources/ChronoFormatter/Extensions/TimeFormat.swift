import ChronoCore

public extension NaiveTime {
    @inlinable
    func rfc3339(digits: Int = 0) -> String {
        let capacity = 8 + (digits > 0 ? 1 + digits : 0)
        if #available(macOS 11.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                raw.printTime(self, at: &cursor)
                raw.printFraction(self.nanosecond, digits: digits, at: &cursor)
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                raw.printTime(self, at: &cursor)
                raw.printFraction(self.nanosecond, digits: digits, at: &cursor)
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }
}

extension NaiveTime: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}
