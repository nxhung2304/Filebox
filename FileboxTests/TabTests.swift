import XCTest
@testable import Filebox

final class TabTests: XCTestCase {
    private let homeURL = URL(fileURLWithPath: "/Users/test", isDirectory: true)
    private let projectsURL = URL(fileURLWithPath: "/Users/test/Projects", isDirectory: true)
    private let downloadsURL = URL(fileURLWithPath: "/Users/test/Downloads", isDirectory: true)

    func testNavigationRecordsBackHistoryAndClearsForward() {
        var tab = Tab(directoryURL: homeURL)
        tab.recordNavigation(to: projectsURL)
        XCTAssertTrue(tab.goBack())
        XCTAssertTrue(tab.canGoForward)

        tab.recordNavigation(to: downloadsURL)

        XCTAssertEqual(tab.directoryURL, downloadsURL)
        XCTAssertEqual(tab.backHistory, [homeURL])
        XCTAssertFalse(tab.canGoForward)
    }

    func testBackThenForwardReturnsToSameFolder() {
        var tab = Tab(directoryURL: homeURL)
        tab.recordNavigation(to: projectsURL)

        XCTAssertTrue(tab.goBack())
        XCTAssertEqual(tab.directoryURL, homeURL)
        XCTAssertTrue(tab.goForward())
        XCTAssertEqual(tab.directoryURL, projectsURL)
        XCTAssertFalse(tab.goForward())
    }

    func testNavigatingToSameFolderDoesNotAddHistory() {
        var tab = Tab(directoryURL: homeURL)

        tab.recordNavigation(to: URL(fileURLWithPath: "/Users/test/"))

        XCTAssertFalse(tab.canGoBack)
    }
}
