import ChronoCore

public extension NaiveDateTime {
    @inlinable
    init?(_ string: String, with parser: ChronoParser = .compact) {
        guard let parts = parser.parse(string) else { return nil }
        self.init(
            year: Int32(parts.year),
            month: parts.month,
            day: parts.day,
            hour: parts.hour,
            minute: parts.minute,
            second: parts.second,
            nanosecond: Int(parts.nanosecond)
        )
    }
}

public extension DateTime where TZ == FixedOffset {
    @inlinable
    init?(_ string: String, with parser: ChronoParser = .compact) {
        guard let parts = parser.parse(string),
              let offset = parts.offset else { return nil }
        self.init(
            year: Int32(parts.year),
            month: parts.month,
            day: parts.day,
            hour: parts.hour,
            minute: parts.minute,
            second: parts.second,
            nanosecond: Int(parts.nanosecond),
            timezone: FixedOffset(.seconds(offset))
        )
    }
}
