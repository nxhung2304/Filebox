import XCTest
@testable import Filebox

@MainActor
final class DirectoryWatcherTests: XCTestCase {
    private var temporaryDirectory: TemporaryDirectory!

    override func setUp() async throws {
        temporaryDirectory = try TemporaryDirectory()
    }

    override func tearDown() async throws {
        temporaryDirectory.remove()
    }

    func testReportsNewFileInWatchedFolder() throws {
        let changeExpectation = expectation(description: "change reported")
        changeExpectation.assertForOverFulfill = false
        let watcher = DirectoryWatcher { changeExpectation.fulfill() }
        watcher.watch(temporaryDirectory.url)
        defer { watcher.stop() }

        try temporaryDirectory.createFile("new.txt")

        wait(for: [changeExpectation], timeout: 5)
    }

    func testReportsChangeInFolderOpenedThroughSymbolicLink() throws {
        let targetURL = try temporaryDirectory.createFolder("Target")
        let linkURL = temporaryDirectory.url.appending(path: "Link", directoryHint: .isDirectory)
        try FileManager.default.createSymbolicLink(at: linkURL, withDestinationURL: targetURL)
        let changeExpectation = expectation(description: "change reported")
        changeExpectation.assertForOverFulfill = false
        let watcher = DirectoryWatcher { changeExpectation.fulfill() }
        watcher.watch(linkURL)
        defer { watcher.stop() }

        try Data().write(to: targetURL.appending(path: "new.txt"))

        wait(for: [changeExpectation], timeout: 5)
    }

    func testIgnoresChangesInsideSubfolder() throws {
        let subfolderURL = try temporaryDirectory.createFolder("Nested")
        RunLoop.main.run(until: Date().addingTimeInterval(1))
        let changeExpectation = expectation(description: "no change reported")
        changeExpectation.isInverted = true
        let watcher = DirectoryWatcher { changeExpectation.fulfill() }
        watcher.watch(temporaryDirectory.url)
        defer { watcher.stop() }

        try Data().write(to: subfolderURL.appending(path: "deep.txt"))

        wait(for: [changeExpectation], timeout: 2)
    }
}
