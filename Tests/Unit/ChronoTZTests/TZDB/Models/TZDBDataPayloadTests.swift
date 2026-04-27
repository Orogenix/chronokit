@testable import ChronoTZ
import Testing

struct TZDBDataPayloadTests {
    @Test("TZDBDataPayloadTests: findTransitionIndex returns correct index")
    func testFindTransitionIndex() throws {
        // Timeline: 100, 200, 300
        let transitions = try [
            TZDBTransition(unixTime: 100, typeIndex: 0),
            TZDBTransition(unixTime: 200, typeIndex: 1),
            TZDBTransition(unixTime: 300, typeIndex: 2),
        ]
        let payload = try TZDBDataPayload.makePayload(
            transitions: transitions,
            posixRule: "UTC0"
        )

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

    @Test("TZDBDataPayloadTests: findTransitionIndex handles empty transitions")
    func findTransitionIndexEmpty() throws {
        let payload = try TZDBDataPayload.makePayload(posixRule: "UTC0")
        #expect(payload.findTransitionIndex(for: 100) == nil)
    }

    @Test("TZDBDataPayloadTests: findTransitionIndex handles single transition")
    func findTransitionIndexSingle() throws {
        let payload = try TZDBDataPayload.makePayload(
            transitions: [TZDBTransition(unixTime: 100, typeIndex: 0)],
            posixRule: "UTC0"
        )

        #expect(payload.findTransitionIndex(for: 50) == nil)
        #expect(payload.findTransitionIndex(for: 100) == 0)
        #expect(payload.findTransitionIndex(for: 150) == 0)
    }

    @Test("TZDBDataPayloadTests: init compiles POSIX rule correctly")
    func initCompilesPosixRule() {
        let ruleString = "EST5EDT,M3.2.0,M11.1.0"
        let payload = TZDBDataPayload(
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
