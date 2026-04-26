public enum TimeZoneError: Error, Hashable, Sendable {
    case zoneNotFound(String)
}

extension TimeZoneError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.zoneNotFound, .zoneNotFound): return true
        }
    }
}

extension TimeZoneError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .zoneNotFound(zone):
            return "Domain: Time zone identifier '\(zone)' not found."
        }
    }
}
