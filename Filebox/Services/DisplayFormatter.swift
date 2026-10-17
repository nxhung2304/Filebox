import Foundation

enum DisplayFormatter {
    private static let englishLocale = Locale(identifier: "en_US_POSIX")

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
        return ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .file)
    }
}
