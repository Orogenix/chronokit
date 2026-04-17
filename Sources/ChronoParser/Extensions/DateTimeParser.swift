import ChronoCore
import ChronoMath

public extension NaiveDateTime {
    @inlinable
    init?(rfc3339 string: String) {
        var input = string

        let parsed: (date: ParsedDate, time: ParsedTime)? = input.withUTF8 { buffer -> (ParsedDate, ParsedTime)? in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let date = ChronoScanner.scanDateRFC3339(from: raw, at: &cursor) else { return nil }

            guard cursor < raw.count else { return nil }
            let separator = raw[cursor]
            guard separator == ASCII.charT
                || separator == ASCII.lowerT
                || separator == ASCII.space
            else { return nil }
            cursor += 1

            guard let time = ChronoScanner.scanTimeRFC3339(from: raw, at: &cursor) else { return nil }

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

    @inlinable
    init?(rfc5322 string: String) {
        var input = string

        let parsed: (date: ParsedDate, time: ParsedTime)? = input.withUTF8 { buffer -> (ParsedDate, ParsedTime)? in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            if ChronoScanner.scanWeekday(from: raw, at: &cursor) != nil {
                guard raw.expect(ASCII.comma, &cursor) else { return nil }
            }
            ChronoScanner.scanFWS(from: raw, at: &cursor)

            guard let date = ChronoScanner.scanDateRFC5322(from: raw, at: &cursor) else { return nil }
            ChronoScanner.scanFWS(from: raw, at: &cursor)

            guard let time = ChronoScanner.scanTimeRFC5322(from: raw, at: &cursor),
                  cursor == raw.count else { return nil }

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

    @inlinable
    init?(rfc5322 string: String) {
        let parsed: (date: ParsedDate, time: ParsedTime, offset: Int)? = Instant.parsedRFC5322(string)

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
