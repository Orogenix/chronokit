public enum CLIError: Error, Equatable, Hashable {
    case usage
    case missingValue(String)
    case invalidFormat(String)
}

public extension CLIError {
    var message: String {
        switch self {
        case .usage:
            return "Usage: ChronoTZGen --input <path> --output <path> [--format bin|swift]"
        case let .missingValue(key):
            return "Error: Missing value for flag '\(key)'"
        case let .invalidFormat(f):
            return "Error: Unknown format '\(f)'. Use 'bin' or 'swift'."
        }
    }
}
