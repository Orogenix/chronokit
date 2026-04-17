import ChronoCore
import ChronoMath

public extension Instant {
    @inlinable
    func rfc3339(digits: Int = 0) -> String {
        let capacity = 32
        let utc = naiveDateTimeUTC()

        if #available(macOS 11.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0

                raw.printDate(utc.date, at: &cursor)
                raw.writeByte(ASCII.charT, at: &cursor)
                raw.printTime(utc.time, at: &cursor)

                if digits > 0 {
                    raw.printFraction(Int64(utc.time.nanosecond), digits: digits, at: &cursor)
                }

                raw.writeByte(ASCII.charZ, at: &cursor)
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0

                raw.printDate(utc.date, at: &cursor)
                raw.writeByte(ASCII.charT, at: &cursor)
                raw.printTime(utc.time, at: &cursor)

                if digits > 0 {
                    raw.printFraction(Int64(utc.time.nanosecond), digits: digits, at: &cursor)
                }

                raw.writeByte(ASCII.charZ, at: &cursor)
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }
}

extension Instant: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}
