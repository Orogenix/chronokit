public protocol LocaleProvider: Sendable {
    var identifier: String { get }
    func name(for month: Month, style: TextStyle) -> String
    func name(for weekday: Weekday, style: TextStyle) -> String
    func dayPeriodName(for hour: Int, style: TextStyle) -> String
}

/// Defines the visual width of localized strings.
public enum TextStyle: Sendable {
    case full // e.g., "January"
    case abbreviated // e.g., "Jan"
    case narrow // e.g., "J"
}
