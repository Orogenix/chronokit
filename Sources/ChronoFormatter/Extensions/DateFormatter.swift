import ChronoCore
import ChronoMath

public extension NaiveDate {
    @inlinable
    func rfc3339() -> String {
        let capacity = 10
        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(into: raw, at: &cursor)
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(into: raw, at: &cursor)
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }

    @inlinable
    func rfc5322() -> String? {
        let capacity = 20

        guard let month = Month(rawValue: month) else { return nil }
        let weekday = Weekday(rawValue: weekday)

        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(weekday: weekday, month: month, into: raw, at: &cursor)
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(weekday: weekday, month: month, into: raw, at: &cursor)
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }
}

extension NaiveDate {
    @usableFromInline
    func formatRFC3339(
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        raw.printDate(self, at: &cursor)
    }

    @usableFromInline
    func formatRFC5322(
        weekday: Weekday?,
        month: Month,
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        if let weekday = weekday {
            raw.printWeekday(weekday, at: &cursor)
            raw.writeByte(ASCII.comma, at: &cursor)
            raw.writeByte(ASCII.space, at: &cursor)
        }

        raw.write2(day, at: &cursor)
        raw.writeByte(ASCII.space, at: &cursor)

        raw.printMonth(month, at: &cursor)
        raw.writeByte(ASCII.space, at: &cursor)

        raw.write4(year, at: &cursor)
    }
}

extension NaiveDate: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}
