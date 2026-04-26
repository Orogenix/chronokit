import ChronoCore
import ChronoMath

public extension Instant {
    @inlinable
    func rfc3339(digits: Int = 0) -> String {
        let capacity = 32
        let utc = plainDateTimeUTC()

        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(
                    utc: utc,
                    digits: digits,
                    into: raw,
                    at: &cursor
                )
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(
                    utc: utc,
                    digits: digits,
                    into: raw,
                    at: &cursor
                )
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }

    @inlinable
    func rfc5322() -> String? {
        let capacity = 40
        let utc = plainDateTimeUTC()

        guard let month = Month(rawValue: utc.date.month) else { return nil }
        let weekday = Weekday(rawValue: utc.date.weekday)

        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(
                    utc: utc,
                    weekday: weekday,
                    month: month,
                    into: raw,
                    at: &cursor
                )
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(
                    utc: utc,
                    weekday: weekday,
                    month: month,
                    into: raw,
                    at: &cursor
                )
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }

    @available(
        *,
        deprecated,
        renamed: "rfc5322()",
        message: "RFC 2822 is obsolete. Use `Instant.rfc5322()` instead (per RFC 5322 Section 3.3)."
    )
    @inlinable
    @inline(__always)
    func rfc2822() -> String? {
        rfc5322()
    }
}

extension Instant {
    @usableFromInline
    func formatRFC3339(
        utc: PlainDateTime,
        digits: Int,
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        utc.formatRFC3339(
            digits: digits,
            offset: .zero,
            into: raw,
            at: &cursor
        )
    }

    @usableFromInline
    func formatRFC5322(
        utc: PlainDateTime,
        weekday: Weekday?,
        month: Month,
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        utc.formatRFC5322(
            weekday: weekday,
            month: month,
            offset: .zero,
            into: raw,
            at: &cursor
        )
    }
}

extension Instant: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}
