import ChronoCore

public extension Instant {
    @inlinable
    init?(_ string: String, with parser: ChronoParser = .compact) {
        guard let parts = parser.parse(string),
              let offset = parts.offset,
              let naive = NaiveDateTime(
                  year: Int32(parts.year),
                  month: parts.month,
                  day: parts.day,
                  hour: parts.hour,
                  minute: parts.minute,
                  second: parts.second,
                  nanosecond: Int(parts.nanosecond)
              )
        else { return nil }

        let timezone = FixedOffset(.seconds(offset))

        self = naive.instant(offset: timezone)
    }
}
