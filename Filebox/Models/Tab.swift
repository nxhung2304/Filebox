import Foundation

struct Tab: Identifiable, Hashable, Sendable {
    let id = UUID()
    var directoryURL: URL
    var items: [FileItem]
    var selectedItemIDs: Set<FileItem.ID>

    var title: String { directoryURL.lastPathComponent }
}
