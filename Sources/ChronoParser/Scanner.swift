import ChronoCore
import ChronoMath

@usableFromInline
enum ChronoScanner {
    @usableFromInline
    @inline(__always)
    static func scanDate(from raw: UnsafeRawBufferPointer, at offset: Int) -> (parsed: ParsedDate, consumed: Int)? {
        guard raw.count >= offset + 10,
              let year = FixedReader.read4(from: raw, at: offset),
              raw[offset + 4] == ASCII.dash,
              let month = FixedReader.read2(from: raw, at: offset + 5),
              raw[offset + 7] == ASCII.dash,
              let day = FixedReader.read2(from: raw, at: offset + 8)
        else { return nil }
        return (ParsedDate(year: year, month: month, day: day), 10)
    }

    @usableFromInline
    @inline(__always)
    static func scanTime(from raw: UnsafeRawBufferPointer, at offset: Int) -> (parsed: ParsedTime, consumed: Int)? {
        guard raw.count >= offset + 8,
              let hour = FixedReader.read2(from: raw, at: offset),
              raw[offset + 2] == ASCII.colon,
              let minute = FixedReader.read2(from: raw, at: offset + 3),
              raw[offset + 5] == ASCII.colon,
              let second = FixedReader.read2(from: raw, at: offset + 6)
        else { return nil }

        var nanosecond: Int64 = 0
        var cursor = offset + 8

        if cursor < raw.count,
           raw[cursor] == ASCII.dot || raw[cursor] == ASCII.comma,
           let fraction = FixedReader.readFraction(from: raw, at: cursor)
        {
            nanosecond = fraction.value
            cursor += fraction.consumed
        }

        return (ParsedTime(hour: hour, minute: minute, second: second, nanosecond: nanosecond), cursor - offset)
    }

    @usableFromInline
    @inline(__always)
    static func scanOffset(from buffer: UnsafeRawBufferPointer, at offset: Int) -> (second: Int, consumed: Int)? {
        guard offset < buffer.count else { return nil }

        let char = buffer[offset]

        if char == ASCII.charZ || char == ASCII.lowerZ {
            return (0, 1)
        }

        // Check for sign: handle ±
        let isNegative = char == ASCII.dash
        let isPositive = char == ASCII.plus
        guard isNegative || isPositive else { return nil }

        // Must have at least ±HH
        guard buffer.count >= 3,
              let hour = FixedReader.read2(from: buffer, at: offset + 1)
        else { return nil }

        var cursor = offset + 3
        var minute = 0

        // Check for minutes: handle ±HH:MM or ±HHMM
        if cursor < buffer.count {
            let hasSeparator = buffer[cursor] == ASCII.colon
            let minutesReadIndex = hasSeparator ? cursor + 1 : cursor

            // If there are at least 2 more digits, read them as minutes
            if buffer.count >= minutesReadIndex + 2,
               let min = FixedReader.read2(from: buffer, at: minutesReadIndex)
            {
                minute = min
                cursor = minutesReadIndex + 2
            }
        }

        let seconds = hour * Seconds.perHour + minute * Seconds.perMinute
        return (isNegative ? -seconds : seconds, cursor - offset)
    }
}
