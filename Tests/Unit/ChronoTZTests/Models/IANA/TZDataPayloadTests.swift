@testable import ChronoTZ
import Testing

struct TZDataPayloadTests {
    @Test("TZDataPayloadTests: findTransitionIndex returns correct index")
    func testFindTransitionIndex() {
        // Timeline: 100, 200, 300
        let transitions = [
            Transition(unixTime: 100, typeIndex: 0),
            Transition(unixTime: 200, typeIndex: 1),
            Transition(unixTime: 300, typeIndex: 2),
        ]
        let payload = createTestPayload(transitions: transitions)

        // Before first transition
        #expect(payload.findTransitionIndex(for: 50) == nil)

        // Exact match on first
        #expect(payload.findTransitionIndex(for: 100) == 0)

        // Between first and second
        #expect(payload.findTransitionIndex(for: 150) == 0)

        // Exact match on middle
        #expect(payload.findTransitionIndex(for: 200) == 1)

        // After last transition
        #expect(payload.findTransitionIndex(for: 350) == 2)
    }

    @Test("TZDataPayloadTests: findTransitionIndex handles empty transitions")
    func findTransitionIndexEmpty() {
        let payload = createTestPayload(transitions: [])
        #expect(payload.findTransitionIndex(for: 100) == nil)
    }

    @Test("*Tests TZDataPayloadTests: findTransitionIndex handles single transition")
    func findTransitionIndexSingle() {
        let payload = createTestPayload(transitions: [Transition(unixTime: 100, typeIndex: 0)])

        #expect(payload.findTransitionIndex(for: 50) == nil)
        #expect(payload.findTransitionIndex(for: 100) == 0)
        #expect(payload.findTransitionIndex(for: 150) == 0)
    }

    @Test("TZDataPayloadTests: init compiles POSIX rule correctly")
    func initCompilesPosixRule() {
        let ruleString = "EST5EDT,M3.2.0,M11.1.0"
        let payload = TZDataPayload(
            transitionCount: 0,
            typeCount: 0,
            transitions: [],
            types: [],
            posixRule: ruleString
        )

        // Verify that the initializer successfully processed the raw string
        #expect(payload.posixRule == ruleString)
        #expect(payload.compiledPosixRule != nil)
    }
}

// MARK: - Helpers

extension TZDataPayloadTests {
    private func createTestPayload(transitions: [Transition] = []) -> TZDataPayload {
        return TZDataPayload(
            transitionCount: UInt32(transitions.count),
            typeCount: 0,
            transitions: transitions,
            types: [],
            posixRule: "UTC0"
        )
    }
}
