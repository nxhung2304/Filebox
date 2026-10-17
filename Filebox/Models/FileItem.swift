import Foundation

struct FileItem: Identifiable, Hashable, Sendable {
    let url: URL
    let name: String
    let isDirectory: Bool
    let size: Int64?
    let dateModified: Date
    let kind: String
    let isHidden: Bool
    let isSymbolicLink: Bool

    var id: URL { url }
}
