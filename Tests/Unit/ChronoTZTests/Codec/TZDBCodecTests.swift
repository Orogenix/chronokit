@testable import ChronoTZ
import Testing

struct TZDBCodecTests {
    @Test("TZDBCodecTests: Round-trip encoding and decoding (Complex payload)")
    func roundTripComplex() throws {
        let original = TZDataPayload(
            transitionCount: 1,
            typeCount: 1,
            transitions: [Transition(unixTime: 1_777_636_800, typeIndex: 1)],
            types: [TypeDefinition(offset: 3600, isDST: 1)],
            posixRule: "UTC+8"
        )

        let encodedData = try TZDBCodec.encode(original)
        let decoded = try TZDBCodec.decode(from: encodedData)

        #expect(decoded.transitionCount == original.transitionCount)
        #expect(decoded.typeCount == original.typeCount)
        #expect(decoded.transitions == original.transitions)
        #expect(decoded.types == original.types)
        #expect(decoded.posixRule == original.posixRule)
    }

    @Test("TZDBCodecTests: Round-trip encoding and decoding (Empty/Minimal payload)")
    func roundTripEmpty() throws {
        let original = TZDataPayload(
            transitionCount: 0,
            typeCount: 0,
            transitions: [],
            types: [],
            posixRule: nil
        )

        let encodedData = try TZDBCodec.encode(original)
        let decoded = try TZDBCodec.decode(from: encodedData)

        #expect(decoded.transitions.isEmpty)
        #expect(decoded.types.isEmpty)
        #expect(decoded.posixRule == nil)
    }
}
