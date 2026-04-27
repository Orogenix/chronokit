public enum BinaryError: Error, Equatable, Hashable, Sendable {
    case prematureEOF
    case bufferOverflow
    case memoryAccessFailed
}

extension BinaryError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .prematureEOF:
            return "Binary: Unexpected end of file/buffer."
        case .bufferOverflow:
            return "Binary: Buffer overflow prevented."
        case .memoryAccessFailed:
            return "Binary: Memory access violation."
        }
    }
}
