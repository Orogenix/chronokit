import ChronoCore
import ChronoMath

public extension NaiveDateTime {
    @inlinable
    init?(rfc3339 string: String) {
        var input = string

        let parsed: (date: ParsedDate, time: ParsedTime)? = input.withUTF8 { buffer -> (ParsedDate, ParsedTime)? in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let date = ChronoScanner.scanDate(from: raw, at: &cursor) else { return nil }

            guard cursor < raw.count else { return nil }
            let separator = raw[cursor]
            guard separator == ASCII.charT
                || separator == ASCII.lowerT
                || separator == ASCII.space
            else { return nil }
            cursor += 1

            guard let time = ChronoScanner.scanTime(from: raw, at: &cursor) else { return nil }

            if cursor < raw.count {
                guard ChronoScanner.scanOffset(from: raw, at: &cursor) != nil else { return nil }
            }

            guard cursor == raw.count else { return nil }

            return (date, time)
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
}

public extension DateTime where TZ == FixedOffset {
    @inlinable
    init?(rfc3339 string: String) {
        let parsed: (date: ParsedDate, time: ParsedTime, offset: Int)? = Instant.parsedRFC3339(string)

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
