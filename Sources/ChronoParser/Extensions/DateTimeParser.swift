import ChronoCore
import ChronoMath

extension NaiveDateTime {
    @inlinable
    public init?(_ string: String, as standard: ChronoStandard = .rfc3339) {
        let parsed: (date: ParsedDate, time: ParsedTime)? = switch standard {
        case .rfc3339:
            Self.parsedRFC3339(string)
        }

        guard let parsed else { return nil }

        self.init(
            year: Int32(parsed.date.year),
            month: parsed.date.month,
            day: parsed.date.day,
            hour: parsed.time.hour,
            minute: parsed.time.minute,
            second: parsed.time.second,
            nanosecond: Int(parsed.time.nanosecond)
        )
    }

    @inlinable
    static func parsedRFC3339(_ string: String) -> (date: ParsedDate, time: ParsedTime)? {
        var input = string

        return input.withUTF8 { buffer -> (ParsedDate, ParsedTime)? in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let parsedDate = ChronoScanner.scanDate(from: raw, at: cursor) else { return nil }
            cursor += parsedDate.consumed

            guard cursor < raw.count else { return nil }

            let separator = raw[cursor]
            guard separator == ASCII.charT
                || separator == ASCII.lowerT
                || separator == ASCII.space
            else { return nil }
            cursor += 1

            guard let parsedTime = ChronoScanner.scanTime(from: raw, at: cursor) else { return nil }
            cursor += parsedTime.consumed

            if cursor < raw.count {
                guard let parsedOffset = ChronoScanner.scanOffset(from: raw, at: cursor) else { return nil }
                cursor += parsedOffset.consumed
            }

            guard cursor == raw.count else { return nil }

            return (parsedDate.parsed, parsedTime.parsed)
        }
    }
}

public extension DateTime where TZ == FixedOffset {
    @inlinable
    init?(_ string: String, as standard: ChronoStandard = .rfc3339) {
        let parsed: (date: ParsedDate, time: ParsedTime, offset: Int)? = switch standard {
        case .rfc3339:
            Instant.parsedRFC3339(string)
        }

        guard let parsed else { return nil }

        let timezone = FixedOffset(.seconds(parsed.offset))

        self.init(
            year: Int32(parsed.date.year),
            month: parsed.date.month,
            day: parsed.date.day,
            hour: parsed.time.hour,
            minute: parsed.time.minute,
            second: parsed.time.second,
            nanosecond: Int(parsed.time.nanosecond),
            timezone: timezone
        )
    }
}
