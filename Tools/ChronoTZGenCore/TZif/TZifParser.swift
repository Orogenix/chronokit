import ChronoSystem
import ChronoTZ

/// An Time Zone Information Format (TZif) parser compliant with RFC 8536.
package enum TZifParser {
    /// Parses a raw byte stream into a structured ``TZDBDataPayload``.
    ///
    /// This decoder is optimized for modern TZif files (Version 2+). It gracefully parses
    /// the legacy Version 1 header and data block, discards them, and synchronizes
    /// with the Version 2+ header for accurate 64-bit time representations.
    ///
    /// ### File Structure
    /// TZif files consist of two concatenated parts in version 2+ files:
    ///
    /// | Section | Description |
    /// | :--- | :--- |
    /// | **V1 Header** | Legacy header (32-bit times). |
    /// | **V1 Data** | Legacy data block. |
    /// | **V2+ Header** | Modern header (64-bit times). |
    /// | **V2+ Data** | Modern data block containing transitions |
    /// | **Footer** | POSIX rules. |
    ///
    /// - Parameter bytes: A raw `[UInt8]` array containing the TZif file contents.
    /// - Returns: A populated ``TZDBDataPayload`` containing the parsed transition and type definitions.
    /// - Throws: ``TZifError`` if the file is truncated, missing magic bytes, or contains malformed data structures.
    ///
    /// - Note: This implementation requires a V2+ file. It uses a "sync-to-magic" approach
    ///   to locate the V2 header, ensuring resilience against minor structural variations.
    package static func parse(from bytes: [UInt8]) throws -> TZDBDataPayload {
        return try bytes.withUnsafeBufferPointer { buffer in
            guard let baseAddress = buffer.baseAddress else { throw TZifError.prematureEOF }
            var reader = BinaryReader(ptr: baseAddress, capacity: buffer.count)

            // 'T' = 0x54, 'Z' = 0x5A, 'i' = 0x69, 'f' = 0x66
            let tzifMagic: [UInt8] = [0x54, 0x5A, 0x69, 0x66]

            // Validate V1 Header
            //
            // A TZif header is structured as follows (the lengths of multi-octet fields are shown in parentheses):
            //
            // +---------------+-----+
            // |    magic (4)  | ver |
            // +---------------+-----+-------------------------------------+
            // |          [unused - reserved for future use] (15)          |
            // +---------------+---------------+---------------+-----------+
            // |  isutcnt (4)  |  isstdcnt (4) |  leapcnt (4)  |
            // +---------------+---------------+---------------+
            // |  timecnt (4)  |  typecnt (4)  |  charcnt (4)  |
            // +---------------+---------------+---------------+

            let magic = try reader.readBytes(count: 4)
            if magic != tzifMagic { throw TZifError.invalidHeader }

            try reader.skip(bytes: 1) // Version
            try reader.skip(bytes: 15) // Reserved

            let ttisutcntV1 = try reader.readBigEndian(Int32.self)
            let ttisstdcntV1 = try reader.readBigEndian(Int32.self)
            let leapcntV1 = try reader.readBigEndian(Int32.self)
            let timecntV1 = try reader.readBigEndian(Int32.self)
            let typecntV1 = try reader.readBigEndian(Int32.self)
            let charcntV1 = try reader.readBigEndian(Int32.self)

            // Skip V1 data blocks
            //
            // In the version 1 data block, time values are 32 bits (TIME_SIZE = 4 octets).
            // The data block is structured as follows (the lengths of multi-octet fields are shown in parentheses):
            //
            // +---------------------------------------------------------+
            // | transition times           (timecnt x TIME_SIZE)        |
            // +---------------------------------------------------------+
            // | transition types           (timecnt)                    |
            // +---------------------------------------------------------+
            // | local time type records    (typecnt x 6)                |
            // +---------------------------------------------------------+
            // | time zone designations     (charcnt)                    |
            // +---------------------------------------------------------+
            // | leap - second records      (leapcnt x (TIME_SIZE + 4))  |
            // +---------------------------------------------------------+
            // | standard / wall indicators (isstdcnt)                   |
            // +---------------------------------------------------------+
            // | UT / local indicators      (isutcnt)                    |
            // +---------------------------------------------------------+
            //                  TZif Data Block

            var skipV1 = 0
            skipV1 += Int(timecntV1 * 4) // transition times (4 byte)
            skipV1 += Int(timecntV1) // transition types
            skipV1 += Int(typecntV1 * 6) // local time type records (4 byte ttyinfo + 1 byte isDST + 1 byte abbrind)
            skipV1 += Int(charcntV1) // time zone designations
            skipV1 += Int(leapcntV1 * 8) // leap-seconds records
            skipV1 += Int(ttisstdcntV1) // standard/wall indicators
            skipV1 += Int(ttisutcntV1) // UT/local indicators
            try reader.skip(bytes: skipV1)

            // Parse V2+ Header
            //
            // A TZif header is structured as follows (the lengths of multi-octet fields are shown in parentheses):
            //
            // +---------------+-----+
            // |    magic (4)  | ver |
            // +---------------+-----+-------------------------------------+
            // |          [unused - reserved for future use] (15)          |
            // +---------------+---------------+---------------+-----------+
            // |  isutcnt (4)  |  isstdcnt (4) |  leapcnt (4)  |
            // +---------------+---------------+---------------+
            // |  timecnt (4)  |  typecnt (4)  |  charcnt (4)  |
            // +---------------+---------------+---------------+

            let foundV2 = try reader.skipUntil(bytes: tzifMagic)
            guard foundV2 else { throw TZifError.corruptionError("V2+ header not found") }

            var skipV2Header = 0
            skipV2Header += 4 // Magic "TZif"
            skipV2Header += 1 // Version 2/3
            skipV2Header += 15 // Reserved
            try reader.skip(bytes: skipV2Header)

            let ttisutcntV2 = try reader.readBigEndian(Int32.self)
            let ttisstdcntV2 = try reader.readBigEndian(Int32.self)
            let leapcntV2 = try reader.readBigEndian(Int32.self)
            let timeCountV2 = try reader.readBigEndian(Int32.self)
            let typeCountV2 = try reader.readBigEndian(Int32.self)
            let charcntV2 = try reader.readBigEndian(Int32.self)

            // V2+ data blocks
            //
            // In the version 2+ data block, present only in version 2 and 3 files,
            // time values are 64 bits (TIME_SIZE = 8 octets).
            //
            // The data block is structured as follows (the lengths of multi-octet fields are shown in parentheses):
            //
            // +---------------------------------------------------------+
            // | transition times           (timecnt x TIME_SIZE)        |
            // +---------------------------------------------------------+
            // | transition types           (timecnt)                    |
            // +---------------------------------------------------------+
            // | local time type records    (typecnt x 6)                |
            // +---------------------------------------------------------+
            // | time zone designations     (charcnt)                    |
            // +---------------------------------------------------------+
            // | leap - second records      (leapcnt x (TIME_SIZE + 4))  |
            // +---------------------------------------------------------+
            // | standard / wall indicators (isstdcnt)                   |
            // +---------------------------------------------------------+
            // | UT / local indicators      (isutcnt)                    |
            // +---------------------------------------------------------+
            //                  TZif Data Block

            // Transitions times
            var transitionsTimes: [Int64] = []
            transitionsTimes.reserveCapacity(Int(timeCountV2))
            for _ in 0 ..< timeCountV2 {
                let unixTime = try reader.readBigEndian(Int64.self)
                transitionsTimes.append(unixTime)
            }

            // Transitions types
            var transitionsTypeIndices: [UInt8] = []
            transitionsTypeIndices.reserveCapacity(Int(timeCountV2))
            for _ in 0 ..< timeCountV2 {
                let typeIndex = try reader.readByte()
                transitionsTypeIndices.append(typeIndex)
            }

            // Transitions zip

            var transitions: [TZDBTransition] = []
            transitions.reserveCapacity(Int(timeCountV2))
            for i in 0 ..< Int(timeCountV2) {
                let unixTime = transitionsTimes[i]
                let typeIndex = transitionsTypeIndices[i]

                guard typeIndex < typeCountV2 else {
                    throw TZifError.invalidTransitionIndex
                }

                try transitions.append(TZDBTransition(unixTime: unixTime, typeIndex: typeIndex))
            }

            // Local time type records
            //
            // Each record has the following format (the lengths of multi-octet fields are shown in parentheses):
            //
            // +---------------+-----+-----+
            // |   utoff (4)   | dst | idx |
            // +---------------+-----+-----+

            var types: [TZDBTypeDefinition] = []
            types.reserveCapacity(Int(typeCountV2))
            for _ in 0 ..< typeCountV2 {
                let utoff = try reader.readBigEndian(Int32.self)
                let isDST = try reader.readByte()
                try reader.skip(bytes: 1) // Skip abbrind
                try types.append(TZDBTypeDefinition(offset: utoff, isDST: isDST))
            }

            // Skip trailing data blocks
            var skipTrailing = 0
            skipTrailing += Int(charcntV2) // time zone designations
            skipTrailing += Int(leapcntV2 * 12) // leap-seconds records
            skipTrailing += Int(ttisstdcntV2) // standard/wall indicators
            skipTrailing += Int(ttisutcntV2) // UT/local indicators
            try reader.skip(bytes: skipTrailing)

            // --- POSIX Rule ---
            //
            // The TZif footer is structured as follows (the lengths of multi-octet fields are shown in parentheses):
            //
            // +----+--------------------+----+
            // | NL |  TZ string (0...)  | NL |
            // +----+--------------------+----+
            //          TZif Footer
            //
            // The TZif footer is present only in version 2 and 3 files,
            // as the obsolescent version 1 format was designed before the need for a footer was apparent.

            var posixRule: String?
            if reader.remainingBytes > 0 {
                let remainingBytes = try reader.readBytes(count: reader.remainingBytes)

                if let fullString = String(bytes: remainingBytes, encoding: .utf8) {
                    let trimmed = fullString.trimmingCharacters(in: .whitespacesAndNewlines)
                    posixRule = trimmed.isEmpty ? nil : trimmed
                }
            }

            return TZDBDataPayload(
                transitionCount: UInt32(timeCountV2),
                typeCount: UInt32(typeCountV2),
                transitions: transitions,
                types: types,
                posixRule: posixRule
            )
        }
    }
}
