public enum PackerError: Error, Equatable, Hashable {
    case cannotReadFile(path: String)
    case invalidPayload(path: String)
    case bufferOverflow(path: String)
}

public extension PackerError {
    var message: String {
        switch self {
        case let .cannotReadFile(path):
            return "Packer Error: Failed to read file at '\(path)'."
        case let .invalidPayload(path):
            return "Packer Error: Invalid TZDBDataPayload in file at '\(path)'."
        case let .bufferOverflow(path):
            return "Packer Error: Failed to serialize TZDBDataPayload from '\(path)'."
        }
    }
}
