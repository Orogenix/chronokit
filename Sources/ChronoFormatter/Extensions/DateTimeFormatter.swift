import ChronoCore
import ChronoMath

public extension NaiveDateTime {
    @inlinable
    func rfc3339(digits: Int = 0, offset: FixedOffset? = nil) -> String {
        let capacity = 48
        let duration = offset?.offset(for: self).resolve(using: .preferEarlier)

        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(
                    digits: digits,
                    offset: duration,
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
                    digits: digits,
                    offset: duration,
                    into: raw,
                    at: &cursor
                )
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }

    @inlinable
    func rfc5322(offset: FixedOffset? = nil) -> String? {
        let capacity = 32
        let duration = offset?.offset(for: self).resolve(using: .preferEarlier)

        guard let month = Month(rawValue: month) else { return nil }
        let weekday = Weekday(rawValue: weekday)

        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(
                    weekday: weekday,
                    month: month,
                    offset: duration,
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
                    weekday: weekday,
                    month: month,
                    offset: duration,
                    into: raw,
                    at: &cursor
                )
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }
}

extension NaiveDateTime {
    @usableFromInline
    func formatRFC3339(
        digits: Int,
        offset: Duration?,
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        raw.printDate(date, at: &cursor)
        raw.writeByte(ASCII.charT, at: &cursor)
        raw.printTime(time, at: &cursor)

        if digits > 0 {
            raw.printFraction(Int64(time.nanosecond), digits: digits, at: &cursor)
        }

        if let offset {
            raw.printOffsetRFC3339(offset.seconds, at: &cursor)
        }
    }

    @usableFromInline
    func formatRFC5322(
        weekday: Weekday?,
        month: Month,
        offset: Duration?,
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
        raw.writeByte(ASCII.space, at: &cursor)

        raw.printTime(time, at: &cursor)

        if let offset {
            raw.writeByte(ASCII.space, at: &cursor)
            raw.printOffsetRFC5322(offset.seconds, at: &cursor)
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
        let duration = timezone.offset(for: instant)

        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(
                    digits: digits,
                    offset: duration,
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
                    digits: digits,
                    offset: duration,
                    into: raw,
                    at: &cursor
                )
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }

    @inlinable
    func rfc5322(digits _: Int = 0) -> String? {
        let capacity = 48

        guard let month = Month(rawValue: month) else { return nil }
        let weekday = Weekday(rawValue: weekday)
        let duration = timezone.offset(for: instant)

        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(
                    weekday: weekday,
                    month: month,
                    offset: duration,
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
                    weekday: weekday,
                    month: month,
                    offset: duration,
                    into: raw,
                    at: &cursor
                )
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }
}

extension DateTime {
    @usableFromInline
    func formatRFC3339(
        digits: Int,
        offset: Duration?,
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        naive.formatRFC3339(
            digits: digits,
            offset: offset,
            into: raw,
            at: &cursor
        )
    }

    @usableFromInline
    func formatRFC5322(
        weekday: Weekday?,
        month: Month,
        offset: Duration?,
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        naive.formatRFC5322(
            weekday: weekday,
            month: month,
            offset: offset,
            into: raw,
            at: &cursor
        )
    }
}

extension DateTime: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}
