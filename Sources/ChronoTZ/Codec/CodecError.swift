public enum CodecError: Error, Equatable, Hashable, Sendable {
    case invalidHeader
    case invalidTransitionTime
    case invalidTransitionIndex
    case invalidUTOffset
    case unsupportedOffsetRange
    case prematureEOF
    case bufferOverflow
    case memoryAccessFailed
    case corruptionError(String)
}

extension CodecError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidHeader:
            return "Codec: Invalid TZif header detected."
        case .invalidUTOffset:
            return "Codec: Invalid UT Offset detected."
        case .invalidTransitionTime:
            return "Codec: Invalid transition unix time detected."
        case .invalidTransitionIndex:
            return "Codec: Invalid transition type detected."
        case .unsupportedOffsetRange:
            return "Codec: Type definition offset out of bound."
        case .prematureEOF:
            return "Codec: Unexpected end of file/buffer."
        case .bufferOverflow:
            return "Codec: Buffer overflow prevented."
        case .memoryAccessFailed:
            return "Codec: Memory access violation."
        case let .corruptionError(reason):
            return "Codec: Data corruption - \(reason)"
        }
    }
}
