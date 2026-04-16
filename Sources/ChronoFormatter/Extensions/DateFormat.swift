import ChronoCore

public extension NaiveDate {
    @inlinable
    func rfc3339() -> String {
        let capacity = 10
        if #available(macOS 11.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                ChronoPrinter.printDate(date: self, to: raw, at: &cursor)
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                ChronoPrinter.printDate(date: self, to: raw, at: &cursor)
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }
}

extension NaiveDate: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}
