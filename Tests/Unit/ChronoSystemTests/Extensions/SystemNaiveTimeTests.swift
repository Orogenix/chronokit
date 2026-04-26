import ChronoCore
import ChronoMath
@testable import ChronoSystem
import Testing

struct SystemPlainTimeTests {
    // MARK: - Initialization Tests

    @Test("SystemPlainTimeTests: PlainTime.now() basic validation")
    func timeNow() {
        let now = PlainTime.now()

        // Sanity check: hour and minute must be within standard clock bounds
        #expect(now.hour >= 0 && now.hour <= 23)
        #expect(now.minute >= 0 && now.minute <= 59)
        #expect(now.second >= 0 && now.second <= 59)
    }

    @Test("SystemPlainTimeTests: Rapid-fire consistency")
    func rapidConsistency() {
        let zone = FixedOffset(.hours(5))

        for _ in 0 ..< 100 {
            let t = PlainTime.now(in: zone)

            // Validate that we never break standard clock constraints
            #expect(t.hour < 24)
            #expect(t.minute < 60)
            #expect(t.second < 60)
        }
    }

    @Test("SystemPlainTimeTests: Deterministic UTC Initialization")
    func utcDeterminism() {
        let tz = FixedOffset.utc
        let nowUTC = PlainTime.now(in: tz)

        // Ensure that explicit UTC handling doesn't produce weird artifacts
        #expect(nowUTC.hour >= 0 && nowUTC.hour < 24)
        #expect(nowUTC.minute >= 0 && nowUTC.minute < 60)
    }

    @Test("SystemPlainTimeTests: now(in:) reflects specific offsets")
    func timeNowWithOffset() {
        // We use UTC and a +1 hour offset
        let utc = FixedOffset.utc
        let plusOne = FixedOffset(.hours(1))

        let timeUTC = PlainTime.now(in: utc)
        let timePlus1 = PlainTime.now(in: plusOne)

        // Convert to total seconds for easy comparison
        let totalSecondsUTC = Int64(timeUTC.hour) * 3600 + Int64(timeUTC.minute) * 60 + Int64(timeUTC.second)
        let totalSecondsPlus1 = Int64(timePlus1.hour) * 3600 + Int64(timePlus1.minute) * 60 + Int64(timePlus1.second)

        // Logic: (Plus1 - UTC) mod 24h should be exactly 3600 seconds
        // Adding 86400 before modulo handles the midnight wrap-around safely
        let diff = (totalSecondsPlus1 - totalSecondsUTC + 86400) % 86400
        #expect(diff == 3600)
    }

    @Test("SystemPlainTimeTests: Consistency across TimeZoneProtocol")
    func protocolConsistency() {
        let systemZone = SystemTimeZone()

        // The two calls should produce virtually identical results
        let time1 = PlainTime.now() // uses default internal SystemTimeZone
        let time2 = PlainTime.now(in: systemZone) // uses explicit protocol

        // We allow for a 1-second drift in case the clock ticked during execution
        let total1 = time1.nanosecondsSinceMidnight
        let total2 = time2.nanosecondsSinceMidnight
        let drift = abs(total1 - total2)

        #expect(drift < NanoSeconds.perSecond64)
    }

    @Test("SystemPlainTimeTests: Contract alignment with PlainDateTime")
    func contractAlignment() {
        let tz = FixedOffset.utc
        let time = PlainTime.now(in: tz)
        let dt = PlainDateTime.now(in: tz)

        #expect(time.hour == dt.time.hour)
        #expect(time.minute == dt.time.minute)
        #expect(time.second == dt.time.second)
    }
}
