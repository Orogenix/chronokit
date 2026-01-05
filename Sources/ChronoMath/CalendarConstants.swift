@usableFromInline
package enum CalendarConstants {
    @usableFromInline package static let daysPerYear: Int64 = 365
    @usableFromInline package static let yearsPerEra: Int64 = 400 // 400-year Gregorian cycle
    @usableFromInline package static let daysPerEra: Int64 = 146_097 // 400*365 + 97 leap days
    @usableFromInline package static let daysPerEraMinusOne: Int64 = 146_096

    @usableFromInline package static let monthsPerYear: Int64 = 12

    // Number of months that repeating pattern in march based calendar
    @usableFromInline package static let monthHinnant: Int64 = 5
    // Number of days of 5 months that repeating pattern in march based calendar
    @usableFromInline package static let monthHinnantDays: Int64 = 153

    @usableFromInline package static let daysPer4Years: Int64 = 1461
    @usableFromInline package static let daysPer4YearsMinusOne: Int64 = 1460
    @usableFromInline package static let daysPer100Years: Int64 = 36524

    // Days from 0001-03-01 to 1970-01-01
    @usableFromInline package static let marchBasedUnixEpochCivilOffset: Int64 = 719_468
    // Days from 0001-01-01 to 1970-01-01
    @usableFromInline package static let unixEpochCivilOffset: Int64 = 719_162

    @usableFromInline
    package static let daysInMonthCommonYear: [UInt8] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    @usableFromInline
    package static let daysInMonthLeapYear: [UInt8] = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    // Prevent overflow on result year at civil date (year = Int32.max - 1)
    @usableFromInline package static let maxInputDay: Int64 = 784_351_576_411
    // Prevent underflow on result year at civil date (year = Int32.min)
    @usableFromInline package static let minInputDay: Int64 = -784_353_015_833
}
