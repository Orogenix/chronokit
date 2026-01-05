import ChronoCore

public extension NaiveDate {
    @inlinable
    init?(_ string: String, with parser: ChronoParser = .compact) {
        guard let parts = parser.parse(string) else { return nil }
        self.init(year: Int32(parts.year), month: parts.month, day: parts.day)
    }
}
