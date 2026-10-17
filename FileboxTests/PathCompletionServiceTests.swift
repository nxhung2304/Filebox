import XCTest
@testable import Filebox

final class PathCompletionServiceTests: XCTestCase {
    private var temporaryDirectory: TemporaryDirectory!
    private let service = PathCompletionService()

    override func setUpWithError() throws {
        temporaryDirectory = try TemporaryDirectory()
        try temporaryDirectory.createFolder("Projects")
        try temporaryDirectory.createFolder("Photos")
        try temporaryDirectory.createFolder(".hidden")
        try temporaryDirectory.createFile("Proposal.txt")
    }

    override func tearDown() {
        temporaryDirectory.remove()
    }

    func testSuggestsOnlyMatchingFolders() async {
        let suggestions = await service.suggestions(for: temporaryDirectory.url.normalizedFilePath + "/pro")

        XCTAssertEqual(suggestions.map { ($0 as NSString).lastPathComponent }, ["Projects"])
    }

    func testTrailingSlashListsVisibleFolders() async {
        let suggestions = await service.suggestions(for: temporaryDirectory.url.normalizedFilePath + "/")

        XCTAssertEqual(suggestions.map { ($0 as NSString).lastPathComponent }, ["Photos", "Projects"])
    }

    func testDotPrefixIncludesHiddenFolders() async {
        let suggestions = await service.suggestions(for: temporaryDirectory.url.normalizedFilePath + "/.h")

        XCTAssertEqual(suggestions.map { ($0 as NSString).lastPathComponent }, [".hidden"])
    }

    func testExpandsTilde() {
        XCTAssertEqual(service.expandedPath("~/Documents"), NSHomeDirectory() + "/Documents")
    }
}
