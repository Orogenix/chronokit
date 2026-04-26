package enum IANACodec {
    package static func decode(from bytes: [UInt8]) throws -> TZDataPayload {
        return try bytes.withUnsafeBufferPointer { buffer in
            guard let baseAddress = buffer.baseAddress else { throw CodecError.prematureEOF }
            var reader = BinaryReader(ptr: baseAddress, capacity: buffer.count)

            // --- Validate V1 Header ---
            let magic = try [
                reader.readByte(),
                reader.readByte(),
                reader.readByte(),
                reader.readByte(),
            ]
            // 'T' = 0x54, 'Z' = 0x5A, 'i' = 0x69, 'f' = 0x66
            if magic != [0x54, 0x5A, 0x69, 0x66] { throw CodecError.invalidHeader }

            try reader.skip(bytes: 1) // Version
            try reader.skip(bytes: 15) // Reserved

            // Validate standard counts (V1 header)
            let ttisutcntV1 = try reader.readBigEndian(Int32.self)
            let ttisstdcntV1 = try reader.readBigEndian(Int32.self)
            let leapcntV1 = try reader.readBigEndian(Int32.self)
            let timecntV1 = try reader.readBigEndian(Int32.self)
            let typecntV1 = try reader.readBigEndian(Int32.self)
            let charcntV1 = try reader.readBigEndian(Int32.self)

            // Skip V1 data blocks
            var skipV1 = 0
            skipV1 += Int(timecntV1 * 4) // V1 timestamps (32-bit)
            skipV1 += Int(timecntV1) // V1 type indices
            skipV1 += Int(typecntV1 * 6) // V1 types (4 byte ttyinfo + 1 byte isDST + 1 byte abbrind)
            skipV1 += Int(leapcntV1 * 8) // Leap seconds
            skipV1 += Int(ttisstdcntV1) // Std/Wall
            skipV1 += Int(ttisutcntV1) // UT/Local
            skipV1 += Int(charcntV1) // Abbr
            try reader.skip(bytes: skipV1)

            // --- Parse V2 Header ---
            var foundV2 = false
            while reader.remainingBytes >= 4 {
                let next4 = try reader.peekBytes(count: 4)
                if next4 == [0x54, 0x5A, 0x69, 0x66] {
                    foundV2 = true
                    break
                }
                try reader.skip(bytes: 1)
            }

            guard foundV2 else { throw CodecError.invalidHeader }

            var skipV2Header = 0
            skipV2Header += 4 // Magic "TZif"
            skipV2Header += 1 // Version 2
            skipV2Header += 15 // Reserved
            try reader.skip(bytes: skipV2Header)

            let ttisutcntV2 = try reader.readBigEndian(Int32.self) // ttisutcnt
            let ttisstdcntV2 = try reader.readBigEndian(Int32.self) // ttisstdcnt
            let leapcntV2 = try reader.readBigEndian(Int32.self) // leapcnt
            let timeCountV2 = try reader.readBigEndian(Int32.self)
            let typeCountV2 = try reader.readBigEndian(Int32.self)
            let charcntV2 = try reader.readBigEndian(Int32.self) // charcnt

            // --- Transitions ---
            var transitionsTimes: [Int64] = []
            transitionsTimes.reserveCapacity(Int(timeCountV2))
            for _ in 0 ..< timeCountV2 {
                let unixTime = try reader.readBigEndian(Int64.self)
                transitionsTimes.append(unixTime)
            }

            var transitionsTypeIndices: [UInt8] = []
            transitionsTypeIndices.reserveCapacity(Int(timeCountV2))
            for _ in 0 ..< timeCountV2 {
                let typeIndex = try reader.readByte()
                transitionsTypeIndices.append(typeIndex)
            }

            var transitions: [Transition] = []
            transitions.reserveCapacity(Int(timeCountV2))
            for i in 0 ..< Int(timeCountV2) {
                let unixTime = transitionsTimes[i]
                let typeIndex = transitionsTypeIndices[i]
                transitions.append(Transition(unixTime: unixTime, typeIndex: typeIndex))
            }

            // --- Type Definitions ---
            var types: [TypeDefinition] = []
            types.reserveCapacity(Int(typeCountV2))
            for _ in 0 ..< typeCountV2 {
                let gmtoff = try reader.readBigEndian(Int32.self)
                let isDST = try reader.readByte()
                try reader.skip(bytes: 1) // Skip abbrind
                types.append(TypeDefinition(offset: gmtoff, isDST: isDST))
            }

            // --- Skip Trailing Data Blocks ---
            var skipTrailing = 0
            skipTrailing += Int(leapcntV2 * 12)
            skipTrailing += Int(ttisstdcntV2)
            skipTrailing += Int(ttisutcntV2)
            skipTrailing += Int(charcntV2)
            try reader.skip(bytes: skipTrailing)

            // --- POSIX Rule ---
            var posixRule: String?
            if reader.remainingBytes > 0 {
                let remainingBytes = try reader.readBytes(count: reader.remainingBytes)

                if let fullString = String(bytes: remainingBytes, encoding: .utf8) {
                    let trimmed = fullString.trimmingCharacters(in: .whitespacesAndNewlines)
                    posixRule = trimmed.isEmpty ? nil : trimmed
                }
            }

            return TZDataPayload(
                transitionCount: UInt32(timeCountV2),
                typeCount: UInt32(typeCountV2),
                transitions: transitions,
                types: types,
                posixRule: posixRule
            )
        }
    }
}
