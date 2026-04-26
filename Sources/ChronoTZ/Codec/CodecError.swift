public enum CodecError: Error, Equatable, Hashable, Sendable {
    case invalidHeader
    case prematureEOF
    case bufferOverflow
    case memoryAccessFailed
    case corruptionError(String)
}

extension CodecError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidHeader:
            return "Codec: Invalid TZDB header detected."
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
