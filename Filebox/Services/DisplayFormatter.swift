import Foundation

enum DisplayFormatter {
    private static let englishLocale = Locale(identifier: "en_US_POSIX")
    private static let bytesPerUnit: Int64 = 1000
    private static let sizeUnits = ["KB", "MB", "GB", "TB", "PB"]
    private static let roundingThreshold = 0.5
    private static let oneDecimalLimit = 100.0
    private static let oneDecimalRoundingThreshold = 0.05

    static func dateText(for date: Date, now: Date = .now, calendar: Calendar = .current) -> String {
        let timeText = date.formatted(Date.VerbatimFormatStyle(
            format: "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
            timeZone: calendar.timeZone,
            calendar: calendar
        ))
        if calendar.isDate(date, inSameDayAs: now) {
            return "Today " + timeText
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday " + timeText
        }
        let monthDayStyle = Date.FormatStyle(locale: englishLocale, calendar: calendar, timeZone: calendar.timeZone)
            .month(.abbreviated)
            .day()
        if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            return date.formatted(monthDayStyle)
        }
        return date.formatted(monthDayStyle.year())
    }

    static func sizeText(for byteCount: Int64?) -> String {
        guard let byteCount else { return "—" }
        if byteCount == 1 { return "1 byte" }
        if byteCount < bytesPerUnit { return "\(byteCount) bytes" }
        var value = Double(byteCount)
        var unitIndex = -1
        while value >= Double(bytesPerUnit) - roundingThreshold, unitIndex < sizeUnits.count - 1 {
            value /= Double(bytesPerUnit)
            unitIndex += 1
        }
        let format = value < oneDecimalLimit - oneDecimalRoundingThreshold ? "%.1f %@" : "%.0f %@"
        return String(format: format, value, sizeUnits[unitIndex])
    }
}
