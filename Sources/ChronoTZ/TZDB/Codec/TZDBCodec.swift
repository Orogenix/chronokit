import ChronoSystem

package enum TZDBCodec {
    package static func encode(_ payload: TZDataPayload) throws -> [UInt8] {
        let ruleBytes = Array(payload.posixRule?.utf8 ?? "".utf8)
        // 8 (counts) + transitions + types + 4 (rule len) + rule bytes
        let size = 8
            + (payload.transitions.count * Transition.size)
            + (payload.types.count * TypeDefinition.size)
            + 4
            + ruleBytes.count

        var data = [UInt8](repeating: 0, count: size)

        try data.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else { throw TZDBError.memoryAccessFailed }

            var writer = BinaryWriter(ptr: baseAddress, capacity: buffer.count)

            try writer.writeBigEndian(UInt32(payload.transitions.count))
            try writer.writeBigEndian(UInt32(payload.types.count))

            for transition in payload.transitions {
                try writer.writeBigEndian(transition.unixTime)
                try writer.writeByte(transition.typeIndex)
            }

            for type in payload.types {
                try writer.writeBigEndian(type.offset)
                try writer.writeByte(type.isDST)
            }

            try writer.writeBigEndian(UInt32(ruleBytes.count))
            if !ruleBytes.isEmpty {
                try writer.writeBytes(ruleBytes)
            }
        }

        return data
    }

    package static func decode(from data: [UInt8]) throws -> TZDataPayload {
        return try data.withUnsafeBufferPointer { buffer in
            try Self.decode(from: UnsafeRawBufferPointer(buffer))
        }
    }

    package static func decode(from buffer: UnsafeRawBufferPointer) throws -> TZDataPayload {
        guard let baseAddress = buffer.baseAddress else { throw TZDBError.prematureEOF }
        var reader = BinaryReader(ptr: baseAddress, capacity: buffer.count)

        let transitionCount = try reader.readBigEndian(UInt32.self)
        let typeCount = try reader.readBigEndian(UInt32.self)

        var transitions: [Transition] = []
        transitions.reserveCapacity(Int(transitionCount))
        for _ in 0 ..< transitionCount {
            let time = try reader.readBigEndian(Int64.self)
            let typeIndex = try reader.readByte()
            try transitions.append(Transition(unixTime: time, typeIndex: typeIndex))
        }

        var types: [TypeDefinition] = []
        types.reserveCapacity(Int(typeCount))
        for _ in 0 ..< typeCount {
            let offsetVal = try reader.readBigEndian(Int32.self)
            let isDST = try reader.readByte()
            try types.append(TypeDefinition(offset: offsetVal, isDST: isDST))
        }

        let ruleLength = try reader.readBigEndian(UInt32.self)
        var posixRule: String?

        if ruleLength > 0 {
            let rawString = try reader.readString(length: ruleLength)
            posixRule = rawString.isEmpty ? nil : rawString
        }

        return TZDataPayload(
            transitionCount: transitionCount,
            typeCount: typeCount,
            transitions: transitions,
            types: types,
            posixRule: posixRule
        )
    }
}
