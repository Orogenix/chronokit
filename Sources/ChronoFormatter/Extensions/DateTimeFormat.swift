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

                ChronoPrinter.printDate(date: self.date, to: raw, at: &cursor)
                cursor += FixedWriter.writeChar(ASCII.charT, to: raw, at: cursor)
                ChronoPrinter.printTime(time: self.time, to: raw, at: &cursor)

                if digits > 0 {
                    ChronoPrinter.printFraction(Int64(self.time.nanosecond), digits: digits, to: raw, at: &cursor)
                }

                if let duration = offset?.offset(for: self).resolve(using: .preferEarlier) {
                    ChronoPrinter.printOffset(duration.seconds, to: raw, at: &cursor)
                }

                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0

                ChronoPrinter.printDate(date: self.date, to: raw, at: &cursor)
                cursor += FixedWriter.writeChar(ASCII.charT, to: raw, at: cursor)
                ChronoPrinter.printTime(time: self.time, to: raw, at: &cursor)

                if digits > 0 {
                    ChronoPrinter.printFraction(Int64(self.time.nanosecond), digits: digits, to: raw, at: &cursor)
                }

                if let duration = offset?.offset(for: self).resolve(using: .preferEarlier) {
                    ChronoPrinter.printOffset(duration.seconds, to: raw, at: &cursor)
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

                ChronoPrinter.printDate(date: self.naive.date, to: raw, at: &cursor)
                cursor += FixedWriter.writeChar(ASCII.charT, to: raw, at: cursor)
                ChronoPrinter.printTime(time: self.naive.time, to: raw, at: &cursor)

                if digits > 0 {
                    ChronoPrinter.printFraction(Int64(self.nanosecond), digits: digits, to: raw, at: &cursor)
                }

                let duration = self.timezone.offset(for: self.instant)
                ChronoPrinter.printOffset(duration.seconds, to: raw, at: &cursor)

                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0

                ChronoPrinter.printDate(date: self.naive.date, to: raw, at: &cursor)
                cursor += FixedWriter.writeChar(ASCII.charT, to: raw, at: cursor)
                ChronoPrinter.printTime(time: self.naive.time, to: raw, at: &cursor)

                if digits > 0 {
                    ChronoPrinter.printFraction(Int64(self.nanosecond), digits: digits, to: raw, at: &cursor)
                }

                let duration = self.timezone.offset(for: self.instant)
                ChronoPrinter.printOffset(duration.seconds, to: raw, at: &cursor)

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
