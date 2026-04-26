import ChronoCore
@testable import ChronoTZ
import Testing

// MARK: - Instant Lookup Tests

struct TimeZoneInfoTests {
    @Test("TimeZoneInfoTests: Historical transition")
    func instantHistoricalOffset() {
        let types = [TypeDefinition(offset: 3600, isDST: 0)]
        let transitions = [Transition(unixTime: 1000, typeIndex: 0)]
        let payload = makePayload(transitions: transitions, types: types)
        let tz = TimeZoneInfo(identifier: "Test/Zone", payload: payload)

        let instant = Instant(seconds: 1500, nanoseconds: 0)
        let offset = tz.offset(for: instant)

        #expect(offset == .seconds(3600))
    }

    @Test("TimeZoneInfoTests: Exact boundary transition")
    func instantBoundaryTransition() {
        // Test exactly AT the transition second
        let types = [
            TypeDefinition(offset: 0, isDST: 0),
            TypeDefinition(offset: 3600, isDST: 1),
        ]
        let transitions = [Transition(unixTime: 1000, typeIndex: 1)]
        let payload = makePayload(transitions: transitions, types: types)
        let tz = TimeZoneInfo(identifier: "Test/Zone", payload: payload)

        // At T=1000, should be the new offset (3600)
        let instant = Instant(seconds: 1000, nanoseconds: 0)
        #expect(tz.offset(for: instant) == .seconds(3600))
    }
}

// MARK: - Local Offset Tests

extension TimeZoneInfoTests {
    @Test("TimeZoneInfoTests: Handles empty payload (Default offset)")
    func localOffsetDefault() throws {
        // No transitions/types, should default to 0
        let payload = makePayload(transitions: [], types: [TypeDefinition(offset: 0, isDST: 0)])
        let tz = TimeZoneInfo(identifier: "Empty/Zone", payload: payload)

        let localTime = try #require(NaiveDateTime(year: 2026, month: 4, day: 24, second: 0, nanosecond: 0))
        let result = tz.offset(for: localTime)

        if case let .unique(metadata) = result {
            #expect(metadata.duration == .seconds(0))
        } else {
            Issue.record("Expected .unique(0), got \(result)")
        }
    }

    @Test("TimeZoneInfoTests: Ambiguous for overlapping time (Fall Back)")
    func localOffsetAmbiguous() throws {
        // Setup: Fall back transition at 01:00 UTC
        // Types: 0 = Standard (0s), 1 = DST (3600s)
        let types = [
            TypeDefinition(offset: 0, isDST: 0),
            TypeDefinition(offset: 3600, isDST: 1),
        ]

        // Initial state set to DST (Index 1) at start of day,
        // then transition to Standard (Index 0) at 01:00 UTC (1_776_992_400)
        let transitions = [
            Transition(unixTime: 1_776_988_800, typeIndex: 1), // 2026-04-24T00:00:00Z
            Transition(unixTime: 1_776_992_400, typeIndex: 0), // 2026-04-24T01:00:00Z
        ]

        let payload = makePayload(transitions: transitions, types: types)
        let tz = TimeZoneInfo(identifier: "Test/Zone", payload: payload)

        // Query time: 01:30 AM
        // This local time exists in both the DST period (00:30 UTC)
        // and the Standard period (01:30 UTC).
        let localTime = try #require(NaiveDateTime(
            year: 2026, month: 4, day: 24,
            hour: 1, minute: 30
        ))

        let offset = tz.offset(for: localTime)

        if case let .ambiguous(earlier, later) = offset {
            #expect(earlier.duration.seconds == 3600) // DST
            #expect(later.duration.seconds == 0) // Standard
        } else {
            Issue.record("Expected .ambiguous, got \(offset)")
        }
    }

    @Test("TimeZoneInfoTests: Invalid for non-existent time (Spring Gap)")
    func localOffsetInvalid() throws {
        // Setup: Spring gap transition at 01:00 UTC
        // Types: 0 = Standard (0s), 1 = DST (3600s)
        let types = [
            TypeDefinition(offset: 0, isDST: 0),
            TypeDefinition(offset: 3600, isDST: 1),
        ]

        // Initial state set to Standard (Index 0) at start of day,
        // then transition to DST (Index 1) at 01:00 UTC (1_776_992_400)
        let transitions = [
            Transition(unixTime: 1_776_988_800, typeIndex: 0), // 2026-04-24T00:00:00Z
            Transition(unixTime: 1_776_992_400, typeIndex: 1), // 2026-04-24T01:00:00Z
        ]

        let payload = makePayload(transitions: transitions, types: types)
        let tz = TimeZoneInfo(identifier: "Test/Zone", payload: payload)

        // Query time: 01:30 AM
        // This local time doesn't exists in both the DST period (00:30 UTC)
        // and the Standard period (01:30 UTC).
        let localTime = try #require(NaiveDateTime(year: 2026, month: 4, day: 24, hour: 1, minute: 30))

        let offset = tz.offset(for: localTime)

        #expect(offset == .invalid, "Expected .invalid, got \(offset)")
    }
}

// MARK: - POSIX Fallback Tests

extension TimeZoneInfoTests {
    @Test("TimeZoneInfoTests: POSIX Fallback")
    func instantPOSIXFallback() {
        let payload = makePayload(
            transitions: [],
            types: [TypeDefinition(offset: 0, isDST: 0)],
            posixRule: "UTC0" // Basic rule
        )
        let tz = TimeZoneInfo(identifier: "Test/Zone", payload: payload)

        let instant = Instant(seconds: 999_999_999, nanoseconds: 0)
        let offset = tz.offset(for: instant)

        #expect(offset == .seconds(0))
    }

    @Test("TimeZoneInfoTests: POSIX Fallback with DST rules")
    func instantPOSIXFallbackWithDST() {
        // Define a last transition in the past (e.g., 2020)
        let lastTransitionTime: Int64 = 1_577_836_800 // Jan 1, 2020
        let transitions = [Transition(unixTime: lastTransitionTime, typeIndex: 0)]
        let types = [TypeDefinition(offset: -18000, isDST: 0)]

        // Define a POSIX rule for 2026/2027 (Eastern Time)
        // EST5EDT,M3.2.0,M11.1.0
        // Standard: 5 hours behind UTC, DST: 4 hours behind UTC
        let posixRule = "EST5EDT,M3.2.0,M11.1.0"

        let payload = makePayload(
            transitions: transitions,
            types: types, // Standard offset -5h
            posixRule: posixRule
        )
        let tz = TimeZoneInfo(identifier: "Test/EST", payload: payload)

        // Query a date FAR into the future (e.g., 2026-07-04)
        // During July, Eastern Time is in DST (-4h / -14400s)
        let summerInstant = Instant(seconds: 1_783_238_400, nanoseconds: 0)
        let offset = tz.offset(for: summerInstant)

        #expect(offset == .seconds(-14400), "Expected DST offset -14400, got \(offset)")
    }
}

// MARK: - Test Helpers

extension TimeZoneInfoTests {
    private func makePayload(
        transitions: [Transition] = [],
        types: [TypeDefinition] = [TypeDefinition(offset: 0, isDST: 0)],
        posixRule: String? = nil
    ) -> TZDataPayload {
        return TZDataPayload(
            transitionCount: UInt32(transitions.count),
            typeCount: UInt32(types.count),
            transitions: transitions,
            types: types,
            posixRule: posixRule
        )
    }
}
