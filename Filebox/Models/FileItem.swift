import Foundation

struct FileItem: Identifiable, Hashable, Sendable {
    let id: String
    let url: URL
    let name: String
    let isDirectory: Bool
    let size: Int64?
    let dateModified: Date
    let kind: String
    let isHidden: Bool
    let isSymbolicLink: Bool
    let isAlias: Bool

    init(
        url: URL,
        name: String,
        isDirectory: Bool,
        size: Int64?,
        dateModified: Date,
        kind: String,
        isHidden: Bool,
        isSymbolicLink: Bool,
        isAlias: Bool
    ) {
        id = url.normalizedFilePath
        self.url = url
        self.name = name
        self.isDirectory = isDirectory
        self.size = size
        self.dateModified = dateModified
        self.kind = kind
        self.isHidden = isHidden
        self.isSymbolicLink = isSymbolicLink
        self.isAlias = isAlias
    }
}
