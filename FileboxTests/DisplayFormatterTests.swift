import XCTest
@testable import Filebox

final class DisplayFormatterTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    func testFolderSizeShowsDash() {
        XCTAssertEqual(DisplayFormatter.sizeText(for: nil), "—")
    }

    func testDateTodayUsesTwentyFourHourTime() {
        let now = date(2026, 10, 17, 22, 0)
        XCTAssertEqual(DisplayFormatter.dateText(for: date(2026, 10, 17, 9, 40), now: now, calendar: calendar), "Today 09:40")
    }

    func testDateYesterdayUsesTwentyFourHourTime() {
        let now = date(2026, 10, 17, 8, 0)
        XCTAssertEqual(DisplayFormatter.dateText(for: date(2026, 10, 16, 21, 12), now: now, calendar: calendar), "Yesterday 21:12")
    }

    func testDateInCurrentYearShowsMonthAndDay() {
        let now = date(2026, 10, 17)
        XCTAssertEqual(DisplayFormatter.dateText(for: date(2026, 10, 14, 12), now: now, calendar: calendar), "Oct 14")
    }

    func testDateInPreviousYearIncludesYear() {
        let now = date(2026, 10, 17)
        XCTAssertEqual(DisplayFormatter.dateText(for: date(2025, 10, 14, 12), now: now, calendar: calendar), "Oct 14, 2025")
    }
}
