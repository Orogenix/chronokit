@usableFromInline
package enum ASCII {
    // --- Control Characters ---
    @usableFromInline package static let nul: UInt8 = 0 // Null
    @usableFromInline package static let soh: UInt8 = 1 // Start of Heading
    @usableFromInline package static let stx: UInt8 = 2 // Start of Text
    @usableFromInline package static let etx: UInt8 = 3 // End of Text
    @usableFromInline package static let eot: UInt8 = 4 // End of Transmission
    @usableFromInline package static let enq: UInt8 = 5 // Enquiry
    @usableFromInline package static let ack: UInt8 = 6 // Acknowledge
    @usableFromInline package static let bel: UInt8 = 7 // Bell
    @usableFromInline package static let bs: UInt8 = 8 // Backspace
    @usableFromInline package static let tab: UInt8 = 9 // Horizontal Tab
    @usableFromInline package static let lf: UInt8 = 10 // Line Feed
    @usableFromInline package static let vt: UInt8 = 11 // Vertical Tab
    @usableFromInline package static let ff: UInt8 = 12 // Form Feed
    @usableFromInline package static let cr: UInt8 = 13 // Carriage Return
    @usableFromInline package static let so: UInt8 = 14 // Shift Out
    @usableFromInline package static let si: UInt8 = 15 // Shift In
    @usableFromInline package static let dle: UInt8 = 16 // Data Link Escape
    @usableFromInline package static let dc1: UInt8 = 17 // Device Control 1
    @usableFromInline package static let dc2: UInt8 = 18 // Device Control 2
    @usableFromInline package static let dc3: UInt8 = 19 // Device Control 3
    @usableFromInline package static let dc4: UInt8 = 20 // Device Control 4
    @usableFromInline package static let nak: UInt8 = 21 // Negative Acknowledge
    @usableFromInline package static let syn: UInt8 = 22 // Synchronous Idle
    @usableFromInline package static let etb: UInt8 = 23 // End of Trans. Block
    @usableFromInline package static let can: UInt8 = 24 // Cancel
    @usableFromInline package static let em: UInt8 = 25 // End of Medium
    @usableFromInline package static let sub: UInt8 = 26 // Substitute
    @usableFromInline package static let esc: UInt8 = 27 // Escape
    @usableFromInline package static let fs: UInt8 = 28 // File Separator
    @usableFromInline package static let gs: UInt8 = 29 // Group Separator
    @usableFromInline package static let rs: UInt8 = 30 // Record Separator
    @usableFromInline package static let us: UInt8 = 31 // Unit Separator

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
