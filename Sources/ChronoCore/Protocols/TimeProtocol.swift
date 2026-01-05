public protocol TimeProtocol: Equatable, Comparable {
    var hour: Int { get }
    var hour12: (isPM: Bool, hour: Int) { get }

    var minute: Int { get }
    var second: Int { get }
    var nanosecond: Int { get }

    var secondsFromMidnight: Int { get }

    func with(hour: Int) -> Self?
    func with(minute: Int) -> Self?
    func with(second: Int) -> Self?
    func with(nanosecond: Int) -> Self?
}

public extension TimeProtocol {
    @inlinable
    var hour12: (isPM: Bool, hour: Int) {
        let isPM = hour >= 12

        var result = hour % 12
        if result == 0 {
            result = 12
        }

        return (isPM: isPM, hour: result)
    }

    @inlinable
    var secondsFromMidnight: Int {
        hour * 3600
            + minute * 60
            + second
    }
}
