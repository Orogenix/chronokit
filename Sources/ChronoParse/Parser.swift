public struct ChronoParser: Equatable, Hashable, Sendable {
    public enum Strategy: Equatable, Hashable, Sendable {
        /// Separator 'T' (e.g., 2025-12-28T15:00:00)
        case compact

        /// Separator ' ' (e.g., 2025-12-28 15:00:00)
        case expanded

        /// User-defined separator (e.g., '_', '@', etc.)
        case custom(separator: UInt8)
    }

    @usableFromInline
    let strategy: Strategy
}

public extension ChronoParser {
    static let compact = Self(strategy: .compact)
    static let expanded = Self(strategy: .expanded)
}
