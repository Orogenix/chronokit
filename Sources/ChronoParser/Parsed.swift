import ChronoCore

@usableFromInline
struct ParsedDate {
    @usableFromInline let year: Int
    @usableFromInline let month: Int
    @usableFromInline let day: Int
}

@usableFromInline
struct ParsedTime {
    @usableFromInline let hour: Int
    @usableFromInline let minute: Int
    @usableFromInline let second: Int
    @usableFromInline let nanosecond: Int64
}

@usableFromInline
struct ParsedInterval {
    @usableFromInline var month: Int64 = 0
    @usableFromInline var day: Int64 = 0
    @usableFromInline var nanosecond: Int64 = 0

    @usableFromInline
    @inline(__always)
    init() {}
}

extension ParsedInterval {
    @usableFromInline
    @discardableResult
    mutating func sumChecked(year: Int64) -> Bool {
        let (month, mulOverflow) = year.multipliedReportingOverflow(by: 12)
        let (total, sumOverflow) = self.month.addingReportingOverflow(month)
        guard !mulOverflow, !sumOverflow else { return false }
        self.month = total
        return true
    }

    @usableFromInline
    @discardableResult
    mutating func sumChecked(month: Int64) -> Bool {
        let (total, sumOverflow) = self.month.addingReportingOverflow(month)
        guard !sumOverflow else { return false }
        self.month = total
        return true
    }

    @usableFromInline
    @discardableResult
    mutating func sumChecked(day: Int64) -> Bool {
        let (total, sumOverflow) = self.day.addingReportingOverflow(day)
        guard !sumOverflow else { return false }
        self.day = total
        return true
    }

    @usableFromInline
    @discardableResult
    mutating func sumChecked(hour: Int64) -> Bool {
        let (nanos, mulOverflow) = hour.multipliedReportingOverflow(by: NanoSeconds.perHour64)
        let (total, sumOverflow) = nanosecond.addingReportingOverflow(nanos)
        guard !mulOverflow, !sumOverflow else { return false }
        nanosecond = total
        return true
    }

    @usableFromInline
    @discardableResult
    mutating func sumChecked(minute: Int64) -> Bool {
        let (nanos, mulOverflow) = minute.multipliedReportingOverflow(by: NanoSeconds.perMinute64)
        let (total, sumOverflow) = nanosecond.addingReportingOverflow(nanos)
        guard !mulOverflow, !sumOverflow else { return false }
        nanosecond = total
        return true
    }

    @usableFromInline
    @discardableResult
    mutating func sumChecked(second: Int64) -> Bool {
        let (nanos, mulOverflow) = second.multipliedReportingOverflow(by: NanoSeconds.perSecond64)
        let (total, sumOverflow) = nanosecond.addingReportingOverflow(nanos)
        guard !mulOverflow, !sumOverflow else { return false }
        nanosecond = total
        return true
    }

    @usableFromInline
    @discardableResult
    mutating func sumChecked(nanosecond: Int64) -> Bool {
        let (total, sumOverflow) = self.nanosecond.addingReportingOverflow(nanosecond)
        guard !sumOverflow else { return false }
        self.nanosecond = total
        return true
    }
}
