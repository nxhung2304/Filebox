import XCTest
@testable import Filebox

final class FileSystemServiceTests: XCTestCase {
    private var temporaryDirectory: TemporaryDirectory!
    private let service = FileSystemService()

    override func setUpWithError() throws {
        temporaryDirectory = try TemporaryDirectory()
    }

    override func tearDown() {
        temporaryDirectory.remove()
    }

    private func loadItems() async throws -> [FileItem] {
        try await service.loadDirectory(at: temporaryDirectory.url, sortedBy: .name, ascending: true).get()
    }

    func testListsFilesAndFoldersWithAttributes() async throws {
        try temporaryDirectory.createFile("notes.txt", contents: "hello")
        try temporaryDirectory.createFolder("Sources")

        let items = try await loadItems()

        XCTAssertEqual(items.map(\.name), ["Sources", "notes.txt"])
        let folder = try XCTUnwrap(items.first)
        XCTAssertTrue(folder.isDirectory)
        XCTAssertNil(folder.size)
        XCTAssertEqual(folder.kind, "Folder")
        let file = try XCTUnwrap(items.last)
        XCTAssertFalse(file.isDirectory)
        XCTAssertEqual(file.size, 5)
        XCTAssertFalse(file.isHidden)
    }

    func testMarksDotFilesAsHidden() async throws {
        try temporaryDirectory.createFile(".gitignore")

        let items = try await loadItems()

        XCTAssertEqual(items.first?.isHidden, true)
    }

    func testSymbolicLinkToFolderIsNavigableDirectory() async throws {
        let targetURL = try temporaryDirectory.createFolder("Target")
        let linkURL = temporaryDirectory.url.appending(path: "Link")
        try FileManager.default.createSymbolicLink(at: linkURL, withDestinationURL: targetURL)

        let items = try await loadItems()

        let link = try XCTUnwrap(items.first { $0.name == "Link" })
        XCTAssertTrue(link.isSymbolicLink)
        XCTAssertTrue(link.isDirectory)
        XCTAssertFalse(link.isAlias)
    }

    func testMissingDirectoryReturnsNotFound() async {
        let missingURL = temporaryDirectory.url.appending(path: "missing", directoryHint: .isDirectory)

        let result = await service.loadDirectory(at: missingURL, sortedBy: .name, ascending: true)

        XCTAssertEqual(result.failureError, .notFound)
    }

    func testUnreadableDirectoryReturnsPermissionDenied() async throws {
        let lockedURL = try temporaryDirectory.createFolder("Locked")
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: lockedURL.path(percentEncoded: false))
        defer {
            try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: lockedURL.path(percentEncoded: false))
        }

        let result = await service.loadDirectory(at: lockedURL, sortedBy: .name, ascending: true)

        XCTAssertEqual(result.failureError, .permissionDenied)
    }

    func testLoadsTwentyThousandFilesUnderOneSecond() async throws {
        let fileCount = 20_000
        let fileManager = FileManager.default
        for index in 0..<fileCount {
            fileManager.createFile(
                atPath: temporaryDirectory.url.appending(path: "file-\(index).swift").path(percentEncoded: false),
                contents: nil
            )
        }

        let start = ContinuousClock.now
        let items = try await loadItems()
        let elapsed = ContinuousClock.now - start

        XCTAssertEqual(items.count, fileCount)
        XCTAssertLessThan(elapsed, .seconds(1))
    }
}

private extension Result {
    var failureError: Failure? {
        if case .failure(let error) = self { return error }
        return nil
    }
}
