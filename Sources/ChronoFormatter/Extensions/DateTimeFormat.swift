import ChronoCore

public extension DateProtocol where Self: TimeProtocol {
    @inlinable
    func string(with formatter: ChronoFormatter = .iso8601()) -> String {
        formatter.string(date: self, time: self)
    }
}

public extension DateTime {
    @inlinable
    func string(with formatter: ChronoFormatter = .iso8601()) -> String {
        let offset = timezone.offset(for: instant).seconds
        return formatter.string(date: self, time: self, offset: Int(offset))
    }
}

extension NaiveDateTime: CustomStringConvertible {
    public var description: String {
        let formatter: ChronoFormatter = .iso8601(digits: 9)
        return formatter.string(date: self, time: self)
    }
}

extension DateTime: CustomStringConvertible {
    public var description: String {
        let offset = timezone.offset(for: instant).seconds
        let formatter: ChronoFormatter = .iso8601(digits: 9, includeOffset: true, useZulu: true)
        return formatter.string(date: self, time: self, offset: Int(offset))
    }
}
