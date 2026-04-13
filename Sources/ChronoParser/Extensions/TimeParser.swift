import ChronoCore

extension NaiveTime {
    @inlinable
    public init?(_ string: String, as standard: ChronoStandard = .rfc3339) {
        let parsed: ParsedTime? = switch standard {
        case .rfc3339:
            Self.parsedRFC3339(string)
        }

        guard let parsed else { return nil }

        self.init(
            hour: parsed.hour,
            minute: parsed.minute,
            second: parsed.second,
            nanosecond: Int(parsed.nanosecond)
        )
    }

    @inlinable
    static func parsedRFC3339(_ string: String) -> ParsedTime? {
        var parsed: ParsedTime?
        var input = string

        input.withUTF8 { buffer in
            let raw = UnsafeRawBufferPointer(buffer)
            guard let result = ChronoScanner.scanTime(from: raw, at: 0),
                  result.consumed == raw.count else { return }
            parsed = result.parsed
        }

        return parsed
    }
}
