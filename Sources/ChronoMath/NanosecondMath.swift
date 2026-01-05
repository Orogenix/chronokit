@usableFromInline
package enum NanosecondMath {
    @usableFromInline
    static let powersOf10: [Int] = [
        1,
        10,
        100,
        1000,
        10000,
        100_000,
        1_000_000,
        10_000_000,
        100_000_000,
        1_000_000_000,
    ]

    @usableFromInline
    package static func pow10(_ n: Int) -> Int {
        guard n >= 0, n <= 9 else {
            preconditionFailure("pow10 out of supported range (0-9)")
        }
        return powersOf10[n]
    }

    @usableFromInline
    package static func span(forDigits digits: Int) -> Int64 {
        switch digits {
        case 0: 1_000_000_000
        case 1: 100_000_000
        case 2: 10_000_000
        case 3: 1_000_000
        case 4: 100_000
        case 5: 10000
        case 6: 1000
        case 7: 100
        case 8: 10
        default: 1
        }
    }
}

package extension Int {
    @usableFromInline
    var paddedTwoDigit: String {
        self < 10 ? "0\(self)" : String(self)
    }
}
