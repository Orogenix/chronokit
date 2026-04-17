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
    public init?(rfc5322 string: String) {
        let parsed: (date: ParsedDate, time: ParsedTime, offset: Int)? = Self.parsedRFC5322(string)

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

            guard let date = ChronoScanner.scanDateRFC3339(from: raw, at: &cursor) else { return nil }

            guard cursor < raw.count else { return nil }
            let separator = raw[cursor]
            guard separator == ASCII.charT
                || separator == ASCII.lowerT
                || separator == ASCII.space
            else { return nil }
            cursor += 1

            guard let time = ChronoScanner.scanTimeRFC3339(from: raw, at: &cursor),
                  let offset = ChronoScanner.scanOffset(from: raw, at: &cursor)
            else { return nil }

            guard cursor == raw.count else { return nil }

            return (date, time, offset)
        }
    }

    @inlinable
    static func parsedRFC5322(_ string: String) -> (date: ParsedDate, time: ParsedTime, offset: Int)? {
        var input = string

        return input.withUTF8 { buffer -> (ParsedDate, ParsedTime, Int)? in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            if ChronoScanner.scanWeekday(from: raw, at: &cursor) != nil {
                guard raw.expect(ASCII.comma, &cursor) else { return nil }
            }
            ChronoScanner.scanFWS(from: raw, at: &cursor)

            guard let date = ChronoScanner.scanDateRFC5322(from: raw, at: &cursor) else { return nil }
            ChronoScanner.scanFWS(from: raw, at: &cursor)

            guard let time = ChronoScanner.scanTimeRFC5322(from: raw, at: &cursor) else { return nil }
            ChronoScanner.scanFWS(from: raw, at: &cursor)

            guard let offset = ChronoScanner.scanOffset(from: raw, at: &cursor),
                  cursor == raw.count else { return nil }

            return (date, time, offset)
        }
    }
}
