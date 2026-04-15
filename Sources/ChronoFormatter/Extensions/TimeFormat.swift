import ChronoCore

public extension TimeProtocol {
    @_disfavoredOverload
    @inlinable
    func string(with formatter: ChronoFormatter = .timeHyphen) -> String {
        formatter.string(date: NaiveDate.unixEpoch, time: self)
    }
}

extension NaiveTime: CustomStringConvertible {
    public var description: String {
        ChronoFormatter.timeHyphen.string(date: NaiveDate.unixEpoch, time: self)
    }
}
