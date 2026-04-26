import ChronoCore
import ChronoMath

/// # POSIX Timezone (TZ) String Reference
///
/// The `TZ` variable string follows the POSIX standard (IEEE Std 1003.1).
///
/// ## Syntax
/// `std offset [dst [offset] [,startRule [/time] ,endRule [/time]]]`
///
/// ## The Header Grammar
/// The initial segment (`std offset [dst [offset]]`) is parsed in a strict, sequential order.
///
/// ### 1. Standard/DST Names (`std`, `dst`)
/// Names are not a fixed list but dynamic identifiers defined by:
/// - **Extended Format (`<...>`):** Everything enclosed in angle brackets is treated as the name.
///   This supports special characters, numbers, and long strings (e.g., `<UTC+5:30>`, `<+0530>`).
/// - **Legacy Format (`[A-Za-z]+`):** A sequence of alphabetic characters.
///   Parsing stops immediately upon encountering a non-letter (which triggers the Offset check).
///
/// ### 2. Offsets (`offset`)
/// Format: `[+|-]hh[:mm[:ss]]`
/// - **The POSIX Trap:** POSIX sign conventions are the **inverse of ISO-8601**.
///   - `+` indicates the time is **behind** UTC (West).
///   - `-` indicates the time is **ahead** of UTC (East).
/// - **Example:** `EST5` implies `Local = UTC - 5`.
///
/// ### 3. DST Offset Defaults
/// If the `dst` name is provided but the `dst offset` is missing, the default is defined as:
/// - `dst_offset = std_offset + 1 hour`.
///
/// ## Transition Rules (`startRule` and `endRule`)
/// These define when to switch between standard and DST. If omitted, the engine defaults to
/// `M4.1.0/02:00:00` (start) and `M10.5.0/02:00:00` (end).
///
/// ### Rule Formats
/// 1. **Julian (J):** `Jn`
///    - `n`: Day of year (1-365). Feb 29 is ignored; cannot handle leap years.
/// 2. **Zero-based (n):** `n`
///    - `n`: Day of year (0-365). Includes Feb 29.
/// 3. **Month-Week-Day (M):** `Mm.w.d`
///    - `m`: Month (1-12).
///    - `w`: Week (1-5). `5` represents the last occurrence of day `d` in the month.
///    - `d`: Day of week (0-6, where 0 is Sunday).
///
/// ## Time Format (`/time`)
/// Optional. Defines the wall-clock time for the transition.
/// - Format: `hh[:mm[:ss]]`
/// - Defaults to `02:00:00` if omitted.
///
/// ## Examples
/// - `EST5EDT,M3.2.0,M11.1.0`
///   - Standard: `EST` (-5). DST: `EDT` (-4).
///   - Starts: 2nd Sunday of March at 2:00:00.
///   - Ends: 1st Sunday of November at 2:00:00.
/// - `<UTC+1>-1<UTC-1>,J60/23:00,J300/1:00`
///   - Quoted names, specific offsets, and Julian-day transitions.
enum POSIXRuleParser {
    static func parse(from text: String) -> POSIXRule? {
        let parts = text.split(separator: ",")

        // Valid: 1 part (Header) OR 3 parts (Header + Start + End)
        guard parts.count == 1 || parts.count == 3 else {
            return nil
        }

        let firstPart = String(parts[0])
        guard let (stdOffset, dstOffset, _) = Self.parseHead(firstPart) else {
            return nil
        }

        let startRule: POSIXRule.RuleTransition
        let endRule: POSIXRule.RuleTransition

        if parts.count == 3 {
            guard let start = Self.parseTransition(String(parts[1])),
                  let end = Self.parseTransition(String(parts[2]))
            else { return nil }
            startRule = start
            endRule = end
        } else {
            startRule = .defaultStart
            endRule = .defaultEnd
        }

        return POSIXRule(
            stdOffset: stdOffset,
            dstOffset: dstOffset,
            startRule: startRule,
            endRule: endRule
        )
    }

    private static func parseHead(_ head: String) -> (Int32, Int32, String)? {
        var cursor = head[...]
        let stdName = consumeName(from: &cursor)
        guard let stdOffset = consumeOffset(from: &cursor) else { return nil }

        let dstName = consumeName(from: &cursor)

        if dstName.isEmpty {
            return (stdOffset, stdOffset, stdName)
        }

        let dstOffset = consumeOffset(from: &cursor) ?? (stdOffset + Seconds.perHour32)
        return (stdOffset, dstOffset, stdName + "..." + dstName)
    }

    private static func consumeName(from cursor: inout Substring) -> String {
        // Modern POSIX
        if cursor.starts(with: "<"),
           let closing = cursor.firstIndex(of: ">")
        {
            let name = String(cursor[cursor.index(after: cursor.startIndex) ..< closing])
            cursor = cursor[cursor.index(after: closing)...]
            return name
        }

        // Legacy POSIX
        let name = String(cursor.prefix { $0.isLetter })
        cursor = cursor.dropFirst(name.count)
        return name
    }

    private static func consumeOffset(from cursor: inout Substring) -> Int32? {
        // Check if the next char is a sign or a digit (start of offset)
        let isOffsetStart = cursor.first.map { $0.isNumber || $0 == "-" || $0 == "+" } ?? false
        guard isOffsetStart else { return nil }

        // Find where the offset ends (non-digits/colons)
        let end = cursor.firstIndex(
            where: { !$0.isNumber && $0 != ":" && $0 != "-" && $0 != "+" }
        ) ?? cursor.endIndex
        let offsetPart = cursor[..<end]
        cursor = cursor[end...]

        // Safely determine sign and digits
        let isNegative: Bool
        let digits: Substring

        if let first = offsetPart.first {
            if first == "-" {
                isNegative = true
                digits = offsetPart.dropFirst()
            } else if first == "+" {
                isNegative = false
                digits = offsetPart.dropFirst()
            } else {
                // Implicit positive
                isNegative = false
                digits = offsetPart
            }
        } else {
            // Should not be reachable given the isOffsetStart guard
            return nil
        }

        let value = parseOffset(String(digits))

        // Normalize: POSIX (Local-UTC) -> UTC-Relative (UTC-Local)
        // If POSIX is 5 (UTC-5), we return -5.
        // If POSIX is -1 (UTC+1), we return 1.
        return isNegative ? value : -value
    }

    private static func parseOffset(_ str: String) -> Int32 {
        let parts = str.split(separator: ":")

        var seconds: Int32 = 0
        var multiplier: Int32 = Seconds.perHour32

        for part in parts {
            if let val = Int32(part) {
                seconds += val * multiplier
                multiplier /= Seconds.perMinute32
            }
        }

        return seconds
    }

    private static func parseTransition(_ str: String) -> POSIXRule.RuleTransition? {
        let timeParts = str.split(separator: "/")
        guard !timeParts.isEmpty else { return nil }

        let rulePart = timeParts[0]

        let timeSeconds: Int32
        if timeParts.count > 1 {
            timeSeconds = parseOffset(String(timeParts[1]))
        } else {
            timeSeconds = 7200 // Default 2:00:00
        }

        // Handle J format (Skip Feb 29)
        if rulePart.starts(with: "J") {
            guard let val = Int(rulePart.dropFirst()),
                  val >= 1, val <= 365 else { return nil }
            return POSIXRule.RuleTransition(
                type: .julian(dayOfYear: val),
                timeSeconds: timeSeconds
            )
        }

        // Handle n format (Include Feb 29)
        if let val = Int(rulePart),
           val >= 0, val <= 365
        {
            return POSIXRule.RuleTransition(
                type: .dayOfYear(dayOfYear: val),
                timeSeconds: timeSeconds
            )
        }

        // Handle M format (Month.Week.Day)
        if rulePart.starts(with: "M") {
            let components = rulePart.dropFirst().split(separator: ".")

            guard components.count == 3,
                  let month = Int(components[0]), month >= 1, month <= 12,
                  let week = Int(components[1]), week >= 1, week <= 5,
                  let dayOfWeek = Int(components[2]), dayOfWeek >= 0, dayOfWeek <= 6
            else { return nil }

            return POSIXRule.RuleTransition(
                type: .month(month: month, week: week, dayOfWeek: dayOfWeek),
                timeSeconds: timeSeconds
            )
        }

        return nil
    }
}
