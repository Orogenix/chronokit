import ChronoCore
import ChronoMath

extension Instant {
    @inlinable
    public init?(rfc3339 string: String) {
        let parsed: (date: ParsedDate, time: ParsedTime, offset: Int)? = Self.parsedRFC3339(string)

        guard let parsed,
              let naive = NaiveDateTime(
                  year: Int32(parsed.date.year),
                  month: parsed.date.month,
                  day: parsed.date.day,
                  hour: parsed.time.hour,
                  minute: parsed.time.minute,
                  second: parsed.time.second,
                  nanosecond: Int(parsed.time.nanosecond)
              )
        else { return nil }

        let timezone = FixedOffset(.seconds(parsed.offset))

        self = naive.instant(offset: timezone)
    }

    @inlinable
    static func parsedRFC3339(_ string: String) -> (date: ParsedDate, time: ParsedTime, offset: Int)? {
        var input = string

        return input.withUTF8 { buffer -> (ParsedDate, ParsedTime, Int)? in
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

            guard cursor < raw.count else { return nil }

            guard let parsedOffset = ChronoScanner.scanOffset(from: raw, at: cursor) else { return nil }
            cursor += parsedOffset.consumed

            guard cursor == raw.count else { return nil }

            return (parsedDate.parsed, parsedTime.parsed, parsedOffset.second)
        }
    }
}
