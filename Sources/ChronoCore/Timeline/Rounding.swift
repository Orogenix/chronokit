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
