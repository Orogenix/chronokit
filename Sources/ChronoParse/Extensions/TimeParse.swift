import ChronoCore

public extension NaiveTime {
    @inlinable
    init?(_ string: String, with parser: ChronoParser = .compact) {
        guard let parts = parser.parse(string) else { return nil }
        self.init(
            hour: parts.hour,
            minute: parts.minute,
            second: parts.second,
            nanosecond: Int(parts.nanosecond),
        )
    }
}
