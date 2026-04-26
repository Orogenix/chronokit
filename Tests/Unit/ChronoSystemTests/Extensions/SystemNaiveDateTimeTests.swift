import ChronoCore
import ChronoMath
@testable import ChronoSystem
import Testing

struct SystemNaiveDateTimeTests {
    @Test("SystemNaiveDateTimeTests: NaiveDateTime.now() matches system year")
    func nowConsistency() {
        let now: NaiveDateTime = .now()
        #expect(now.date.year >= 1970, "Should be more than unix year")
        #expect(now.date.month >= 1 && now.date.month <= 12)
        #expect(now.date.day >= 1 && now.date.day <= 31)
    }

    @Test("SystemNaiveDateTimeTests: now(in: FixedOffset) handles extreme offsets")
    func nowWithOffsets() {
        let plus12 = FixedOffset(.hours(12))
        let minus12 = FixedOffset(.hours(-12))

        let timePlus: NaiveDateTime = .now(in: plus12)
        let timeMinus: NaiveDateTime = .now(in: minus12)

        // The difference between these two wall clocks should be 24 hours
        // We convert them to a simple hour count for comparison
        let hourDiff = (Int(timePlus.date.day) * 24 + Int(timePlus.time.hour))
            - (Int(timeMinus.date.day) * 24 + Int(timeMinus.time.hour))

        // Note: This might be 23, 24, or 25 depending on if the jump crosses a midnight boundary
        #expect(abs(hourDiff) >= 23 && abs(hourDiff) <= 25)
    }

    @Test("SystemNaiveDateTimeTests: Consistency between Instant and Naive now")
    func instantNaiveCohesion() {
        let instant: Instant = .now()
        let tz = SystemTimeZone()

        // Manual conversion
        let manualNaive = instant.naiveDateTime(in: tz)

        // Method conversion
        let autoNaive: NaiveDateTime = .now(in: tz)

        // They should be extremely close (likely identical in seconds)
        #expect(manualNaive.date == autoNaive.date)
        #expect(abs(Int32(manualNaive.time.hour) - Int32(autoNaive.time.hour)) <= 1)
    }

    @Test("SystemNaiveDateTimeTests: UTC absolute consistency")
    func utcAlignment() {
        let now = NaiveDateTime.now(in: FixedOffset.utc)
        let instant = Instant.now()
        let manual = instant.naiveDateTime(in: FixedOffset.utc)

        #expect(now.date == manual.date, "NaiveDateTime(in: .utc) must align with manual Instant conversion")
        #expect(now.time.hour == manual.time.hour, "Hour must match UTC reference")
    }

    @Test("SystemNaiveDateTimeTests: Zone Isolation")
    func zoneIsolation() {
        // Ensure that calling 'now(in:)' returns data strictly
        // bound to the provided timezone, not the system environment.
        let zoneA = FixedOffset(.hours(5))
        let zoneB = FixedOffset(.hours(-5))

        let timeA = NaiveDateTime.now(in: zoneA)
        let timeB = NaiveDateTime.now(in: zoneB)

        // They should have different time components despite being called at the same instant
        #expect(timeA.time.hour != timeB.time.hour)
    }
}
