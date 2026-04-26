@testable import ChronoTZGenCore
import Testing

struct EmitterTypeTests {
    @Test("EmitterTypeTests: Factory returns the correct concrete emitter type")
    func factoryReturnsCorrectType() {
        #expect(EmitterType.bin.emitter is BinaryEmitter, "bin should return BinaryEmitter")
        #expect(EmitterType.c.emitter is CEmitter, "c should return CEmitter")
        #expect(EmitterType.swift.emitter is SwiftEmitter, "swift should return SwiftEmitter")
    }
}
