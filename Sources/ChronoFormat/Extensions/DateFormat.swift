import ChronoCore

public extension DateProtocol {
    @_disfavoredOverload
    @inlinable
    func string(with formatter: ChronoFormatter = .dateHyphen) -> String {
        formatter.string(date: self, time: NaiveTime.midnight)
    }
}

extension NaiveDate: CustomStringConvertible {
    public var description: String {
        ChronoFormatter.dateHyphen.string(date: self, time: NaiveTime.midnight)
    }
}
