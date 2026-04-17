import ChronoCore
import ChronoMath

public extension NaiveDateTime {
    @inlinable
    func rfc3339(digits: Int = 0, offset: FixedOffset? = nil) -> String {
        let capacity = 48

        if #available(macOS 11.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0

                raw.printDate(self.date, at: &cursor)
                raw.writeByte(ASCII.charT, at: &cursor)
                raw.printTime(self.time, at: &cursor)

                if digits > 0 {
                    raw.printFraction(Int64(self.time.nanosecond), digits: digits, at: &cursor)
                }

                if let duration = offset?.offset(for: self).resolve(using: .preferEarlier) {
                    raw.printOffset(duration.seconds, at: &cursor)
                }

                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0

                raw.printDate(self.date, at: &cursor)
                raw.writeByte(ASCII.charT, at: &cursor)
                raw.printTime(self.time, at: &cursor)

                if digits > 0 {
                    raw.printFraction(Int64(self.time.nanosecond), digits: digits, at: &cursor)
                }

                if let duration = offset?.offset(for: self).resolve(using: .preferEarlier) {
                    raw.printOffset(duration.seconds, at: &cursor)
                }

                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }
}

extension NaiveDateTime: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}

public extension DateTime {
    @inlinable
    func rfc3339(digits: Int = 0) -> String {
        let capacity = 48

        if #available(macOS 11.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0

                raw.printDate(self.naive.date, at: &cursor)
                raw.writeByte(ASCII.charT, at: &cursor)
                raw.printTime(self.naive.time, at: &cursor)

                if digits > 0 {
                    raw.printFraction(Int64(self.nanosecond), digits: digits, at: &cursor)
                }

                let duration = self.timezone.offset(for: self.instant)
                raw.printOffset(duration.seconds, at: &cursor)

                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0

                raw.printDate(self.naive.date, at: &cursor)
                raw.writeByte(ASCII.charT, at: &cursor)
                raw.printTime(self.naive.time, at: &cursor)

                if digits > 0 {
                    raw.printFraction(Int64(self.nanosecond), digits: digits, at: &cursor)
                }

                let duration = self.timezone.offset(for: self.instant)
                raw.printOffset(duration.seconds, at: &cursor)

                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }
}

extension DateTime: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}
