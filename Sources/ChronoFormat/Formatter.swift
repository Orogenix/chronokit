public struct ChronoFormatter: Equatable, Hashable, Sendable {
    public enum Strategy: Equatable, Hashable, Sendable {
        case dateHyphen
        case timeHyphen
        case dateTimeSpace(digits: Int = 0)

        /// The Universal ISO 8601 Strategy
        /// - digits: Number of fractional seconds (0 to 9)
        /// - includeOffset: Whether to append the timezone offset at all.
        /// - useZulu: If true, offset 0 becomes 'Z'. If false, becomes '+00:00'.
        case iso8601(
            digits: Int = 0,
            includeOffset: Bool = false,
            useZulu: Bool = false
        )
    }

    @usableFromInline
    let strategy: Strategy
}

public extension ChronoFormatter {
    static let dateHyphen = Self(strategy: .dateHyphen)
    static let timeHyphen = Self(strategy: .timeHyphen)

    static func iso8601(
        digits: Int = 0,
        includeOffset: Bool = false,
        useZulu: Bool = false
    ) -> Self {
        Self(strategy: .iso8601(digits: digits, includeOffset: includeOffset, useZulu: useZulu))
    }

    static func dateTimeSpace(digits: Int = 0) -> Self {
        Self(strategy: .dateTimeSpace(digits: digits))
    }
}
