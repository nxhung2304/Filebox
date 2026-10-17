import XCTest
@testable import Filebox

final class FileItemSorterTests: XCTestCase {
    private func item(_ name: String, isDirectory: Bool = false, size: Int64? = nil, modifiedOffset: TimeInterval = 0) -> FileItem {
        FileItem(
            url: URL(fileURLWithPath: "/tmp/\(name)"),
            name: name,
            isDirectory: isDirectory,
            size: isDirectory ? nil : size,
            dateModified: Date(timeIntervalSince1970: modifiedOffset),
            kind: isDirectory ? "Folder" : "Document",
            isHidden: false,
            isSymbolicLink: false,
            isAlias: false
        )
    }

    func testFoldersComeFirstAndNamesSortNaturally() {
        let items = [item("file10.txt"), item("Zeta", isDirectory: true), item("file2.txt"), item("alpha", isDirectory: true)]

        let sortedNames = FileItemSorter.sorted(items, by: .name, ascending: true).map(\.name)

        XCTAssertEqual(sortedNames, ["alpha", "Zeta", "file2.txt", "file10.txt"])
    }

    func testDescendingKeepsFoldersFirst() {
        let items = [item("a.txt"), item("b.txt"), item("Folder", isDirectory: true)]

        let sortedNames = FileItemSorter.sorted(items, by: .name, ascending: false).map(\.name)

        XCTAssertEqual(sortedNames, ["Folder", "b.txt", "a.txt"])
    }

    func testSortsBySize() {
        let items = [item("big", size: 300), item("small", size: 10), item("medium", size: 200)]

        let sortedNames = FileItemSorter.sorted(items, by: .size, ascending: false).map(\.name)

        XCTAssertEqual(sortedNames, ["big", "medium", "small"])
    }

    func testSortsByDateModified() {
        let items = [item("new", modifiedOffset: 300), item("old", modifiedOffset: 10)]

        let sortedNames = FileItemSorter.sorted(items, by: .dateModified, ascending: true).map(\.name)

        XCTAssertEqual(sortedNames, ["old", "new"])
    }
}
