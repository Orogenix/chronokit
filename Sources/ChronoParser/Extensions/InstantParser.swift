import ChronoCore
import ChronoMath

public extension Instant {
    @inlinable
    init?(rfc3339 string: String) {
        let parsed: (date: ParsedDate, time: ParsedTime, offset: Int)? = Self.parsedRFC3339(string)

        guard let parsed,
              let plain = PlainDateTime(
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

        self = plain.instant(offset: timezone)
    }

    @inlinable
    init?(rfc5322 string: String) {
        let parsed: (date: ParsedDate, time: ParsedTime, offset: Int)? = Self.parsedRFC5322(string)

        guard let parsed,
              let plain = PlainDateTime(
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

        self = plain.instant(offset: timezone)
    }

    @available(
        *,
        deprecated,
        renamed: "init(rfc5322:)",
        message: "Use init(rfc5322:) which provides full compatibility with RFC 2822."
    )
    @inlinable
    @inline(__always)
    init?(rfc2822 string: String) {
        self.init(rfc5322: string)
    }
}

extension Instant {
    @inlinable
    static func parsedRFC3339(_ string: String) -> (date: ParsedDate, time: ParsedTime, offset: Int)? {
        var input = string

        return input.withUTF8 { buffer -> (ParsedDate, ParsedTime, Int)? in
            let raw = UnsafeRawBufferPointer(buffer)
            var cursor = 0

            guard let date = raw.scanDateRFC3339(at: &cursor) else { return nil }

            guard cursor < raw.count else { return nil }
            let separator = raw[cursor]
            guard separator == ASCII.charT
                || separator == ASCII.lowerT
                || separator == ASCII.space
            else { return nil }
            cursor += 1

            guard let time = raw.scanTimeRFC3339(at: &cursor),
                  let offset = raw.scanOffset(at: &cursor)
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

            if raw.scanWeekday(at: &cursor) != nil {
                guard raw.expect(ASCII.comma, &cursor) else { return nil }
            }
            raw.scanFWS(at: &cursor)

            guard let date = raw.scanDateRFC5322(at: &cursor) else { return nil }
            raw.scanFWS(at: &cursor)

            guard let time = raw.scanTimeRFC5322(at: &cursor) else { return nil }
            raw.scanFWS(at: &cursor)

            guard let offset = raw.scanOffset(at: &cursor),
                  cursor == raw.count else { return nil }

            return (date, time, offset)
        }
    }
}
