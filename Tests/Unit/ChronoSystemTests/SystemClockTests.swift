import ChronoCore
@testable import ChronoSystem
import Testing

struct SystemClockTests {
    @Test("SystemClockTests: Basic Functionality")
    func nowReturnsValidTime() {
        let clock = SystemClock.shared
        let time = clock.now()

        // Sanity Check: Ensure the time is not in the past (e.g., before 2020)
        // 1.7B seconds is roughly the epoch for 2024
        #expect(time.seconds > 1_700_000_000, "Time should be a valid Unix epoch")

        // Nanoseconds must be within valid range [0, 999,999,999]
        #expect(time.nanoseconds >= 0 && time.nanoseconds < 1_000_000_000)
    }

    @Test("SystemClockTests: Monotonicity")
    func monotonicity() {
        let clock = SystemClock.shared
        let t1 = clock.now()
        let t2 = clock.now()

        // Time should never go backwards
        // (t2.seconds, t2.nanoseconds) must be >= (t1.seconds, t1.nanoseconds)
        guard t2.seconds > t1.seconds else {
            #expect(t2.nanoseconds >= t1.nanoseconds)
            return
        }
    }
}
