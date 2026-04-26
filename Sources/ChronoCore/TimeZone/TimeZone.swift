public protocol TimeZoneProtocol: Equatable, Hashable, Sendable {
    /// The name of the timezone (e.g., "UTC", "+07:00")
    var identifier: String { get }

    /// Returns the offset in Duration from UTC for a specific UTC timestamp.
    func offset(for instant: Instant) -> Duration

    /// Returns the offset in Duration from plain date time.
    func offset(for plain: PlainDateTime) -> PlainOffset
}

public struct PlainOffsetMetadata: Equatable, Hashable, Sendable {
    public let duration: Duration
    public let isDST: Bool

    public init(
        duration: Duration,
        isDST: Bool
    ) {
        self.duration = duration
        self.isDST = isDST
    }
}

public extension PlainOffsetMetadata {
    static func standard(_ duration: Duration) -> Self {
        Self(duration: duration, isDST: false)
    }

    static func dst(_ duration: Duration) -> Self {
        Self(duration: duration, isDST: true)
    }
}

public enum DSTResolutionPolicy: Equatable, Hashable, Sendable {
    case preferEarlier
    case preferLater
    case strict
}

public enum PlainOffset: Equatable, Hashable, Sendable {
    case unique(PlainOffsetMetadata)
    case ambiguous(earlier: PlainOffsetMetadata, later: PlainOffsetMetadata)
    case invalid
}

public extension PlainOffset {
    @inline(__always)
    func resolve(using policy: DSTResolutionPolicy) -> PlainOffsetMetadata? {
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
