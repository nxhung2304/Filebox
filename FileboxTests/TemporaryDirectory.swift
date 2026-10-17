import Foundation

struct TemporaryDirectory {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appending(path: "FileboxTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    @discardableResult
    func createFile(_ name: String, contents: String = "") throws -> URL {
        let fileURL = url.appending(path: name)
        try Data(contents.utf8).write(to: fileURL)
        return fileURL
    }

    @discardableResult
    func createFolder(_ name: String) throws -> URL {
        let folderURL = url.appending(path: name, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        return folderURL
    }

    func remove() {
        try? FileManager.default.removeItem(at: url)
    }
}
