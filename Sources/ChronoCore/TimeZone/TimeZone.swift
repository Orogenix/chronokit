public protocol TimeZoneProtocol: Equatable, Hashable, Sendable {
    /// The name of the timezone (e.g., "UTC", "+07:00")
    var identifier: String { get }

    /// Returns the offset in Duration from UTC for a specific UTC timestamp.
    func offset(for instant: Instant) -> Duration

    /// Returns the offset in Duration from local date time.
    func offset(for local: NaiveDateTime) -> LocalOffset
}

public enum LocalOffset: Equatable, Hashable, Sendable {
    case unique(Duration)
    case ambiguous(earlier: Duration, later: Duration)
    case invalid
}

public extension LocalOffset {
    @inline(__always)
    func resolve(using policy: DSTResolutionPolicy) -> Duration? {
        switch self {
        case let .unique(offset):
            offset

        case let .ambiguous(earlier, later):
            switch policy {
            case .preferEarlier:
                earlier
            case .preferLater:
                later
            case .strict:
                nil
            }

        case .invalid:
            nil
        }
    }
}

public enum DSTResolutionPolicy: Equatable, Hashable, Sendable {
    case preferEarlier
    case preferLater
    case strict
}

public enum TimeZoneSign: Character, Equatable, Hashable, Sendable {
    case minus = "-"
    case plus = "+"

    @inlinable
    public init?(symbol: String) {
        guard let char = symbol.first, symbol.count == 1 else { return nil }
        self.init(rawValue: char)
    }
}

public extension TimeZoneSign {
    @inlinable
    var multiplier: Int {
        self == .plus ? 1 : -1
    }

    @inlinable
    func apply<T: BinaryInteger>(to value: T) -> T {
        value * T(multiplier)
    }
}
