import ChronoCore
import ChronoMath

@usableFromInline
enum ChronoScanner {
    @usableFromInline
    @inline(__always)
    static func scanDateRFC3339(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> ParsedDate? {
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
    static func scanTimeRFC3339(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> ParsedTime? {
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
    static func scanDateRFC5322(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> ParsedDate? {
        let dayPos = cursor
        guard let day = raw.readVarInt(&cursor),
              (cursor - dayPos) <= 2 else { return nil }

        scanFWS(from: raw, at: &cursor)
        guard let month = scanMonth(from: raw, at: &cursor) else { return nil }

        scanFWS(from: raw, at: &cursor)
        guard let year = raw.read4(&cursor) else { return nil }

        return ParsedDate(year: year, month: month, day: Int(day))
    }

    @usableFromInline
    @inline(__always)
    static func scanTimeRFC5322(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> ParsedTime? {
        guard let hour = raw.read2(&cursor),
              raw.expect(ASCII.colon, &cursor),
              let minute = raw.read2(&cursor)
        else { return nil }

        var second = 0
        var nanosecond: Int64 = 0

        if raw.expect(ASCII.colon, &cursor) {
            guard let sec = raw.read2(&cursor) else { return nil }
            second = sec
            nanosecond = raw.readFraction(&cursor) ?? 0
        }

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

        if cursor + 1 < raw.count {
            let pair = (UInt16(raw[cursor]) << 8) | UInt16(raw[cursor + 1])
            let lowerPair = pair | 0x2020

            // Check for ut
            if lowerPair == 0x7574 {
                cursor += 2
                return 0
            }

            // Check for gmt
            if lowerPair == 0x676D,
               cursor + 2 < raw.count,
               (raw[cursor + 2] | 0x20) == 0x74
            {
                cursor += 3
                return 0
            }
        }

        // Check for sign: handle ±
        let isNegative = char == ASCII.dash
        let isPositive = char == ASCII.plus
        guard isNegative || isPositive else { return nil }
        cursor += 1

        // Must have at least ±HH
        guard let hour = raw.read2(&cursor) else { return nil }

        var minute = 0

        // Check for minutes: handle ±HH:MM or ±HHMM
        if cursor < raw.count {
            if raw.expect(ASCII.colon, &cursor) {
                guard let min = raw.read2(&cursor) else { return nil }
                minute = min
            } else if (raw[cursor] ^ 0x30) <= 9 {
                guard let min = raw.read2(&cursor) else { return nil }
                minute = min
            }
        }

        let totalSeconds = hour * Seconds.perHour + minute * Seconds.perMinute
        return isNegative ? -totalSeconds : totalSeconds
    }

    @usableFromInline
    @inline(__always)
    static func scanFWS(from raw: UnsafeRawBufferPointer, at cursor: inout Int) {
        while cursor < raw.count {
            let char = raw[cursor]
            if char == ASCII.space || char == ASCII.tab {
                cursor += 1
            } else if char == ASCII.cr, cursor + 2 < raw.count, raw[cursor + 1] == ASCII.lf {
                let next = raw[cursor + 2]
                if next == ASCII.space || next == ASCII.tab {
                    cursor += 3
                } else {
                    break
                }
            } else {
                break
            }
        }
    }

    @usableFromInline
    @inline(__always)
    static func scanMonth(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> Int? {
        let start = cursor
        guard let triple = raw.pack3(&cursor) else { return nil }

        switch triple {
        case 0x6A616E: return 1 // 'jan'
        case 0x666562: return 2 // 'feb'
        case 0x6D6172: return 3 // 'mar'
        case 0x617072: return 4 // 'apr'
        case 0x6D6179: return 5 // 'may'
        case 0x6A756E: return 6 // 'jun'
        case 0x6A756C: return 7 // 'jul'
        case 0x617567: return 8 // 'aug'
        case 0x736570: return 9 // 'sep'
        case 0x6F6374: return 10 // 'oct'
        case 0x6E6F76: return 11 // 'nov'
        case 0x646563: return 12 // 'dec'
        default:
            cursor = start // Backtrack
            return nil
        }
    }

    @usableFromInline
    @inline(__always)
    static func scanWeekday(from raw: UnsafeRawBufferPointer, at cursor: inout Int) -> Int? {
        let start = cursor
        guard let triple = raw.pack3(&cursor) else { return nil }

        switch triple {
        case 0x6D6F6E: return 1 // 'mon'
        case 0x747565: return 2 // 'tue'
        case 0x776564: return 3 // 'wed'
        case 0x746875: return 4 // 'thu'
        case 0x667269: return 5 // 'fri'
        case 0x736174: return 6 // 'sat'
        case 0x73756E: return 7 // 'sun'
        default:
            cursor = start // Backtrack
            return nil
        }
    }
}
