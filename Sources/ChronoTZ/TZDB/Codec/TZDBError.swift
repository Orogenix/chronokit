public enum TZDBError: Error, Equatable, Hashable, Sendable {
    case invalidHeader
    case invalidTransitionTime
    case invalidUTOffset
    case unsupportedOffsetRange
    case prematureEOF
    case memoryAccessFailed
    case corruptionError(String)
}

extension TZDBError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidHeader:
            return "TZDB: Invalid TZif header detected."
        case .invalidTransitionTime:
            return "TZDB: Invalid transition unix time detected."
        case .invalidUTOffset:
            return "TZDB: Invalid UT Offset detected."
        case .unsupportedOffsetRange:
            return "TZDB: Type definition offset out of bound."
        case .prematureEOF:
            return "TZDB: Unexpected end of file/buffer."
        case .memoryAccessFailed:
            return "TZDB: Memory access violation."
        case let .corruptionError(reason):
            return "TZDB: Data corruption - \(reason)"
        }
    }
}
