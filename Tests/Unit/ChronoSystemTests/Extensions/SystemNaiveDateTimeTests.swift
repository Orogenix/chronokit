import ChronoCore
import ChronoMath
@testable import ChronoSystem
import Testing

struct SystemPlainDateTimeTests {
    @Test("SystemPlainDateTimeTests: PlainDateTime.now() matches system year")
    func nowConsistency() {
        let now: PlainDateTime = .now()
        #expect(now.date.year >= 1970, "Should be more than unix year")
        #expect(now.date.month >= 1 && now.date.month <= 12)
        #expect(now.date.day >= 1 && now.date.day <= 31)
    }

    @Test("SystemPlainDateTimeTests: now(in: FixedOffset) handles extreme offsets")
    func nowWithOffsets() {
        let plus12 = FixedOffset(.hours(12))
        let minus12 = FixedOffset(.hours(-12))

        let timePlus: PlainDateTime = .now(in: plus12)
        let timeMinus: PlainDateTime = .now(in: minus12)

        // The difference between these two wall clocks should be 24 hours
        // We convert them to a simple hour count for comparison
        let hourDiff = (Int(timePlus.date.day) * 24 + Int(timePlus.time.hour))
            - (Int(timeMinus.date.day) * 24 + Int(timeMinus.time.hour))

        // Note: This might be 23, 24, or 25 depending on if the jump crosses a midnight boundary
        #expect(abs(hourDiff) >= 23 && abs(hourDiff) <= 25)
    }

    @Test("SystemPlainDateTimeTests: Consistency between Instant and Plain now")
    func instantPlainCohesion() {
        let instant: Instant = .now()
        let tz = SystemTimeZone()

        // Manual conversion
        let manualPlain = instant.plainDateTime(in: tz)

        // Method conversion
        let autoPlain: PlainDateTime = .now(in: tz)

        // They should be extremely close (likely identical in seconds)
        #expect(manualPlain.date == autoPlain.date)
        #expect(abs(Int32(manualPlain.time.hour) - Int32(autoPlain.time.hour)) <= 1)
    }

    @Test("SystemPlainDateTimeTests: UTC absolute consistency")
    func utcAlignment() {
        let now = PlainDateTime.now(in: FixedOffset.utc)
        let instant = Instant.now()
        let manual = instant.plainDateTime(in: FixedOffset.utc)

        #expect(now.date == manual.date, "PlainDateTime(in: .utc) must align with manual Instant conversion")
        #expect(now.time.hour == manual.time.hour, "Hour must match UTC reference")
    }

    @Test("SystemPlainDateTimeTests: Zone Isolation")
    func zoneIsolation() {
        // Ensure that calling 'now(in:)' returns data strictly
        // bound to the provided timezone, not the system environment.
        let zoneA = FixedOffset(.hours(5))
        let zoneB = FixedOffset(.hours(-5))

        let timeA = PlainDateTime.now(in: zoneA)
        let timeB = PlainDateTime.now(in: zoneB)

        // They should have different time components despite being called at the same instant
        #expect(timeA.time.hour != timeB.time.hour)
    }
}
