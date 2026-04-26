@testable import ChronoCore
import ChronoMath
import Testing

struct SystemInstantTests {
    // MARK: - Initialization Tests

    @Test("SystemInstantTests: Invariant - Nanosecond range")
    func nanosecondRange() {
        let now = Instant.now()

        // Nanoseconds must always be within [0, 999_999_999]
        // If this fails, ChronoMath logic produce incorrect results.
        #expect(now.nanoseconds >= 0, "Nanoseconds must be positive")
        #expect(now.nanoseconds < 1_000_000_000, "Nanoseconds must be less than 1 second")
    }

    @Test("SystemInstantTests: Invariant - Positive Seconds")
    func positiveSeconds() {
        let now = Instant.now()
        #expect(now.seconds >= 0, "Current time should not be in the past relative to the Unix Epoch")
    }

    @Test("SystemInstantTests: Monotonicity under load")
    func monotonicConsistency() {
        let start = Instant.now()

        // Simulate a burst of activity
        for _ in 0 ..< 1000 {
            let current = Instant.now()
            #expect(current >= start, "System clock should be monotonic")
        }
    }

    @Test("SystemInstantTests: Verify Clock Source")
    func verifyClockBehavior() {
        let now = Instant.now()
        let now2 = Instant.now()
        #expect(now2 >= now, "Clock should not move backward during standard operation")
    }

    @Test("SystemInstantTests: High resolution check")
    func highResolution() {
        // Capture many instants in a tight loop
        let count = 100

        var instants: [Instant] = []
        instants.reserveCapacity(count)
        for _ in 0 ..< count {
            instants.append(.now())
        }

        // Verify that we are actually getting different nanosecond values
        // (Ensures the clock isn't just returning whole seconds)
        let uniqueInstants = Set(instants.map { "\($0.seconds).\($0.nanoseconds)" })

        #expect(uniqueInstants.count > 1, "Clock resolution might be too low or stuck")
    }
}
