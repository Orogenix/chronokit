import ChronoCore

extension NaiveDate {
    @inlinable
    public init?(_ string: String, as standard: ChronoStandard = .rfc3339) {
        let parsed: ParsedDate? = switch standard {
        case .rfc3339:
            Self.parsedRFC3339(string)
        }

        guard let parsed else { return nil }

        self.init(
            year: Int32(parsed.year),
            month: UInt8(parsed.month),
            day: UInt8(parsed.day)
        )
    }

    @inlinable
    static func parsedRFC3339(_ string: String) -> ParsedDate? {
        var parsed: ParsedDate?
        var input = string

        input.withUTF8 { buffer in
            guard buffer.count >= 10 else { return }
            let raw = UnsafeRawBufferPointer(buffer)
            parsed = ChronoScanner.scanDate(from: raw, at: 0)?.parsed
        }

        return parsed
    }
}
