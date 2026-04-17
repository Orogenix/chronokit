import ChronoCore

public extension NaiveTime {
    @inlinable
    func rfc3339(digits: Int = 0) -> String {
        let capacity = 8 + (digits > 0 ? 1 + digits : 0)
        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(digits: digits, into: raw, at: &cursor)
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(digits: digits, into: raw, at: &cursor)
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }

    @inlinable
    func rfc5322() -> String {
        let capacity = 8
        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(into: raw, at: &cursor)
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(into: raw, at: &cursor)
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }

    @available(
        *,
        deprecated,
        renamed: "rfc5322()",
        message: "RFC 2822 is obsolete. Use `NaiveTime.rfc5322()` instead (per RFC 5322 Section 3.3)."
    )
    @inlinable
    @inline(__always)
    func rfc2822() -> String {
        rfc5322()
    }
}

extension NaiveTime {
    @usableFromInline
    func formatRFC3339(
        digits: Int,
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        raw.printTime(self, at: &cursor)
        raw.printFraction(nanosecond, digits: digits, at: &cursor)
    }

    @usableFromInline
    func formatRFC5322(
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        raw.printTime(self, at: &cursor)
    }
}

extension NaiveTime: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}
