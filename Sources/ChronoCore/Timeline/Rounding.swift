public protocol SubsecondRoundable {
    /// Round fractional seconds to the given number of decimal digits.
    ///
    /// - Parameter digits: Number of digits (0–9).
    ///   Values ≥ 9 return `self` unchanged.
    func roundSubseconds(_ digits: Int) -> Self

    /// Truncate fractional seconds to the given number of decimal digits.
    ///
    /// - Parameter digits: Number of digits (0–9).
    ///   Values ≥ 9 return `self` unchanged.
    func truncateSubseconds(_ digits: Int) -> Self
}

public protocol DurationRoundable {
    associatedtype RoundingError: Error

    /// Round to the nearest multiple of `quantum`.
    func round(byQuantum quantum: Duration) throws(RoundingError) -> Self

    /// Truncate toward zero to a multiple of `quantum`.
    func truncate(byQuantum quantum: Duration) throws(RoundingError) -> Self

    /// Round away from zero to a multiple of `quantum`.
    func roundUp(byQuantum quantum: Duration) throws(RoundingError) -> Self
}

public enum TimeRoundingError: Error, Equatable {
    /// Quantum is zero or negative
    case invalidQuantum

    /// Duration cannot be represented in nanoseconds
    case quantumExceedsLimit

    /// Timestamp cannot be represented in nanoseconds
    case timestampExceedsLimit
}
