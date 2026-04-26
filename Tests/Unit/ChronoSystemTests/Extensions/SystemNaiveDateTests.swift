import ChronoCore
import ChronoMath
@testable import ChronoSystem
import Testing

struct SystemNaiveDateTests {
    // MARK: - Initialization Tests

    @Test("SystemNaiveDateTests: NaiveDate.now() basic validation")
    func dateNow() {
        let date: NaiveDate = .now()

        // Sanity check: Should be a realistic year in the current era
        #expect(date.year >= 2025)
        #expect(date.month >= 1 && date.month <= 12)
        #expect(date.day >= 1 && date.day <= ChronoMath.lastDayOfMonth(Int64(date.year), UInt8(date.month)))
    }

    @Test("SystemNaiveDateTests: now(in:) respects large offsets (Midnight Crossing)")
    func dateNowWithOffset() {
        // We pick two opposite extreme offsets
        let plus14 = FixedOffset(.hours(14))
        let minus12 = FixedOffset(.hours(-12))

        let datePlus: NaiveDate = .now(in: plus14)
        let dateMinus: NaiveDate = .now(in: minus12)

        // Logic: The date in the furthest east zone (+14) must be equal to
        // or up to 2 days ahead of the furthest west zone (-12),
        // but never behind it.
        let dayDiff = datePlus.daysSinceEpoch - dateMinus.daysSinceEpoch
        #expect(dayDiff >= 0 && dayDiff <= 2)
    }

    @Test("SystemNaiveDateTests: Consistency between NaiveDate.now() and NaiveDate.now(in:)")
    func defaultConsistency() {
        // This test ensures that the parameterless .now()
        // is indeed calling the .now(in: SystemTimeZone()) implementation.
        let date1 = NaiveDate.now()
        let date2 = NaiveDate.now(in: SystemTimeZone())

        #expect(date1 == date2, "Default .now() should match SystemTimeZone implementation")
    }

    @Test("SystemNaiveDateTests: Contract alignment with NaiveDateTime")
    func contractWithDateTime() {
        // Prove that NaiveDate.now(in:) is strictly derived
        // from the NaiveDateTime.now(in:)'s date component.
        let tz = FixedOffset.utc
        let date = NaiveDate.now(in: tz)
        let dateTime = NaiveDateTime.now(in: tz)

        #expect(date == dateTime.date, "NaiveDate.now(in:) must match NaiveDateTime's date component")
        #expect(date.year == dateTime.date.year)
        #expect(date.month == dateTime.date.month)
        #expect(date.day == dateTime.date.day)
    }

    @Test("SystemNaiveDateTests: Protocol Generic Compatibility")
    func protocolCompatibility() {
        // Verifying that the 'some TimeZoneProtocol' constraint
        // accepts our types correctly.
        let tz = FixedOffset.hours(5)
        let date = NaiveDate.now(in: tz)

        // Ensure the date is valid for this specific timezone
        // This implicitly tests that the generic constraint works
        #expect(date.daysSinceEpoch != 0)
    }
}
