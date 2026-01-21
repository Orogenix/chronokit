import ChronoMath

extension ChronoParser {
    @usableFromInline
    func parseParts(
        from raw: UnsafeRawBufferPointer,
        separator: UInt8
    ) -> RawDateTimeParts? {
        guard raw.count >= 10 else { return nil }

        var parts = RawDateTimeParts()

        guard
            let year = FixedReader.read4(from: raw, at: 0),
            raw[4] == ASCII.dash,
            let month = FixedReader.read2(from: raw, at: 5),
            raw[7] == ASCII.dash,
            let day = FixedReader.read2(from: raw, at: 8),
            month >= 0, month <= 12,
            day >= 0, day <= lastDayOfMonth(Int64(year), UInt8(month))
        else { return nil }

        parts.year = year
        parts.month = month
        parts.day = day

        if raw.count == 10 { return parts }

        guard
            raw.count >= 19,
            raw[10] == separator
        else { return nil }

        guard
            let hour = FixedReader.read2(from: raw, at: 11),
            raw[13] == ASCII.colon,
            let minute = FixedReader.read2(from: raw, at: 14),
            raw[16] == ASCII.colon,
            let second = FixedReader.read2(from: raw, at: 17),
            hour >= 0, hour < 24,
            minute >= 0, minute < 60,
            second >= 0, second < 60
        else { return nil }

        parts.hour = hour
        parts.minute = minute
        parts.second = second

        var cursor = 19

        if cursor < raw.count,
           raw[cursor] == ASCII.dot || raw[cursor] == ASCII.comma
        {
            guard let fraction = FixedReader.readFraction(from: raw, at: cursor)
            else { return nil }
            parts.nanosecond = fraction.value
            cursor += fraction.consumed
        }

        parts.offset = FixedReader.readOffset(from: raw, at: cursor)

        return parts
    }
}

extension ChronoParser {
    @inlinable
    func parse(_ string: String) -> RawDateTimeParts? {
        let separator: UInt8 = switch strategy {
        case .compact: ASCII.charT
        case .expanded: ASCII.space
        case let .custom(sep): sep
        }

        return string.utf8.withContiguousStorageIfAvailable { buffer in
            parseParts(from: UnsafeRawBufferPointer(buffer), separator: separator)
        } ?? {
            var utf8 = [UInt8]()
            utf8.reserveCapacity(string.utf8.count)
            utf8.append(contentsOf: string.utf8)

            return utf8.withUnsafeBytes {
                parseParts(from: $0, separator: separator)
            }
        }()
    }
}
