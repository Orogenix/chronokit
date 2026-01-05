@inline(__always)
public func floorDiv(_ numerator: Int64, _ denominator: Int64) -> Int64 {
    precondition(denominator != 0, "floorDiv: denominator must not be zero")

    let truncatedQuotient = numerator / denominator
    let remainder = numerator % denominator

    // If remainder and denominator have opposite signs, truncation was too high.
    let signsDiffer = (numerator < 0) != (denominator < 0)
    let needAdjustment = remainder != 0 && signsDiffer

    return needAdjustment ? (truncatedQuotient - 1) : truncatedQuotient
}

@inline(__always)
public func floorMod(_ numerator: Int64, _ denominator: Int64) -> Int64 {
    precondition(denominator != 0, "floorMod: denominator must not be zero")

    let rawRemainder = numerator % denominator

    let signsDiffer = (rawRemainder < 0) != (denominator < 0)
    let needAdjustment = rawRemainder != 0 && signsDiffer

    return needAdjustment ? (rawRemainder + denominator) : rawRemainder
}
