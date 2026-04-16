import ChronoCore
import ChronoMath

@usableFromInline
enum ChronoScanner {
    @usableFromInline
    @inline(__always)
    static func scanDate(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> ParsedDate? {
        guard let year = raw.read4(&cursor),
              raw.expect(ASCII.dash, &cursor),
              let month = raw.read2(&cursor),
              raw.expect(ASCII.dash, &cursor),
              let day = raw.read2(&cursor)
        else { return nil }
        return ParsedDate(year: year, month: month, day: day)
    }

    @usableFromInline
    @inline(__always)
    static func scanTime(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> ParsedTime? {
        guard let hour = raw.read2(&cursor),
              raw.expect(ASCII.colon, &cursor),
              let minute = raw.read2(&cursor),
              raw.expect(ASCII.colon, &cursor),
              let second = raw.read2(&cursor)
        else { return nil }

        let nanosecond = raw.readFraction(&cursor) ?? 0

        return ParsedTime(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    }

    @usableFromInline
    @inline(__always)
    static func scanOffset(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> Int? {
        guard cursor < raw.count else { return nil }

        let char = raw[cursor]

        // Handle UTC 'Z' or 'z'
        if char == ASCII.charZ || char == ASCII.lowerZ {
            cursor += 1
            return 0
        }

        // Check for sign: handle ±
        let isNegative = char == ASCII.dash
        let isPositive = char == ASCII.plus
        guard isNegative || isPositive else { return nil }

        cursor += 1

        // Must have at least ±HH
        guard let hour = raw.read2(&cursor) else { return nil }

        // var cursor = offset + 3
        var minute = 0

        // Check for minutes: handle ±HH:MM or ±HHMM
        if cursor < raw.count {
            if raw.expect(ASCII.colon, &cursor) {
                guard let min = raw.read2(&cursor) else { return nil }
                minute = min
            } else if let min = raw.read2(&cursor) {
                minute = min
            }
        }

        let totalSeconds = hour * Seconds.perHour + minute * Seconds.perMinute
        return isNegative ? -totalSeconds : totalSeconds
    }
}
