import ChronoSystem

public enum TZifError: Error, Equatable, Hashable, Sendable {
    case invalidHeader
    case invalidTransitionIndex
    case prematureEOF
    case corruptionError(String)
}

extension TZifError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidHeader:
            return "TZif: Invalid TZif header detected."
        case .invalidTransitionIndex:
            return "TZif: Invalid transition type detected."
        case .prematureEOF:
            return "TZif: Unexpected end of file/buffer."
        case let .corruptionError(reason):
            return "TZif: Data corruption - \(reason)"
        }
    }
}
