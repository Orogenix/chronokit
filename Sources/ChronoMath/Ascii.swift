@usableFromInline
package enum ASCII {
    // --- Printable Punctuations & Symbols ---
    @usableFromInline package static let space: UInt8 = 32 // ' '
    @usableFromInline package static let bang: UInt8 = 33 // '!'
    @usableFromInline package static let doubleQuote: UInt8 = 34 // '"'
    @usableFromInline package static let hash: UInt8 = 35 // '#'
    @usableFromInline package static let dollar: UInt8 = 36 // '$'
    @usableFromInline package static let percent: UInt8 = 37 // '%'
    @usableFromInline package static let ampersand: UInt8 = 38 // '&'
    @usableFromInline package static let singleQuote: UInt8 = 39 // '''
    @usableFromInline package static let leftParen: UInt8 = 40 // '('
    @usableFromInline package static let rightParen: UInt8 = 41 // ')'
    @usableFromInline package static let asterisk: UInt8 = 42 // '*'
    @usableFromInline package static let plus: UInt8 = 43 // '+'
    @usableFromInline package static let comma: UInt8 = 44 // ','
    @usableFromInline package static let dash: UInt8 = 45 // '-'
    @usableFromInline package static let dot: UInt8 = 46 // '.'
    @usableFromInline package static let slash: UInt8 = 47 // '/'

    // --- Numbers ---
    @usableFromInline package static let zero: UInt8 = 48
    @usableFromInline package static let one: UInt8 = 49
    @usableFromInline package static let two: UInt8 = 50
    @usableFromInline package static let three: UInt8 = 51
    @usableFromInline package static let four: UInt8 = 52
    @usableFromInline package static let five: UInt8 = 53
    @usableFromInline package static let six: UInt8 = 54
    @usableFromInline package static let seven: UInt8 = 55
    @usableFromInline package static let eight: UInt8 = 56
    @usableFromInline package static let nine: UInt8 = 57

    // --- More Punctuations ---
    @usableFromInline package static let colon: UInt8 = 58 // ':'
    @usableFromInline package static let semicolon: UInt8 = 59 // ';'
    @usableFromInline package static let lessThan: UInt8 = 60 // '<'
    @usableFromInline package static let equal: UInt8 = 61 // '='
    @usableFromInline package static let greaterThan: UInt8 = 62 // '>'
    @usableFromInline package static let question: UInt8 = 63 // '?'
    @usableFromInline package static let at: UInt8 = 64 // '@'

    // --- Uppercase Alphabet ---
    @usableFromInline package static let charA: UInt8 = 65
    @usableFromInline package static let charB: UInt8 = 66
    @usableFromInline package static let charC: UInt8 = 67
    @usableFromInline package static let charD: UInt8 = 68
    @usableFromInline package static let charE: UInt8 = 69
    @usableFromInline package static let charF: UInt8 = 70
    @usableFromInline package static let charG: UInt8 = 71
    @usableFromInline package static let charH: UInt8 = 72
    @usableFromInline package static let charI: UInt8 = 73
    @usableFromInline package static let charJ: UInt8 = 74
    @usableFromInline package static let charK: UInt8 = 75
    @usableFromInline package static let charL: UInt8 = 76
    @usableFromInline package static let charM: UInt8 = 77
    @usableFromInline package static let charN: UInt8 = 78
    @usableFromInline package static let charO: UInt8 = 79
    @usableFromInline package static let charP: UInt8 = 80
    @usableFromInline package static let charQ: UInt8 = 81
    @usableFromInline package static let charR: UInt8 = 82
    @usableFromInline package static let charS: UInt8 = 83
    @usableFromInline package static let charT: UInt8 = 84
    @usableFromInline package static let charU: UInt8 = 85
    @usableFromInline package static let charV: UInt8 = 86
    @usableFromInline package static let charW: UInt8 = 87
    @usableFromInline package static let charX: UInt8 = 88
    @usableFromInline package static let charY: UInt8 = 89
    @usableFromInline package static let charZ: UInt8 = 90

    // --- Brackets & Symbols ---
    @usableFromInline package static let leftBracket: UInt8 = 91 // '['
    @usableFromInline package static let backslash: UInt8 = 92 // '\'
    @usableFromInline package static let rightBracket: UInt8 = 93 // ']'
    @usableFromInline package static let caret: UInt8 = 94 // '^'
    @usableFromInline package static let underscore: UInt8 = 95 // '_'
    @usableFromInline package static let backtick: UInt8 = 96 // '`'

    // --- Lowercase Alphabet ---
    @usableFromInline package static let lowerA: UInt8 = 97
    @usableFromInline package static let lowerB: UInt8 = 98
    @usableFromInline package static let lowerC: UInt8 = 99
    @usableFromInline package static let lowerD: UInt8 = 100
    @usableFromInline package static let lowerE: UInt8 = 101
    @usableFromInline package static let lowerF: UInt8 = 102
    @usableFromInline package static let lowerG: UInt8 = 103
    @usableFromInline package static let lowerH: UInt8 = 104
    @usableFromInline package static let lowerI: UInt8 = 105
    @usableFromInline package static let lowerJ: UInt8 = 106
    @usableFromInline package static let lowerK: UInt8 = 107
    @usableFromInline package static let lowerL: UInt8 = 108
    @usableFromInline package static let lowerM: UInt8 = 109
    @usableFromInline package static let lowerN: UInt8 = 110
    @usableFromInline package static let lowerO: UInt8 = 111
    @usableFromInline package static let lowerP: UInt8 = 112
    @usableFromInline package static let lowerQ: UInt8 = 113
    @usableFromInline package static let lowerR: UInt8 = 114
    @usableFromInline package static let lowerS: UInt8 = 115
    @usableFromInline package static let lowerT: UInt8 = 116
    @usableFromInline package static let lowerU: UInt8 = 117
    @usableFromInline package static let lowerV: UInt8 = 118
    @usableFromInline package static let lowerW: UInt8 = 119
    @usableFromInline package static let lowerX: UInt8 = 120
    @usableFromInline package static let lowerY: UInt8 = 121
    @usableFromInline package static let lowerZ: UInt8 = 122

    // --- Final Punctuations ---
    @usableFromInline package static let leftBrace: UInt8 = 123 // '{'
    @usableFromInline package static let pipe: UInt8 = 124 // '|'
    @usableFromInline package static let rightBrace: UInt8 = 125 // '}'
    @usableFromInline package static let tilde: UInt8 = 126 // '~'
    @usableFromInline package static let del: UInt8 = 127
}
