import Foundation

enum SampleData {
    static let projectURL = URL(fileURLWithPath: NSHomeDirectory()).appending(path: "Projects/filebox/Sources")

    static func sourcesTab(now: Date = .now) -> Tab {
        let items = [
            folder("Views", modified: now.addingTimeInterval(-600)),
            folder("Models", modified: now.addingTimeInterval(-86_400)),
            folder("Services", modified: now.addingTimeInterval(-1_200)),
            folder(".build", modified: now.addingTimeInterval(-300), isHidden: true),
            file("AppState.swift", size: 3_100, kind: "Swift", modified: now.addingTimeInterval(-1_800)),
            file("FileBrowserView.swift", size: 6_800, kind: "Swift", modified: now.addingTimeInterval(-600)),
            file("FileItem.swift", size: 1_400, kind: "Swift", modified: now.addingTimeInterval(-3 * 86_400)),
            file("DirectoryWatcher.swift", size: 2_200, kind: "Swift", modified: now.addingTimeInterval(-3_600)),
            file("KeyboardShortcuts.swift", size: 1_900, kind: "Swift", modified: now.addingTimeInterval(-2 * 86_400)),
            file("PreviewPane.swift", size: 4_000, kind: "Swift", modified: now.addingTimeInterval(-86_400)),
            file("SearchEngine.swift", size: 5_300, kind: "Swift", modified: now.addingTimeInterval(-5 * 86_400)),
            file(".gitignore", size: 96, kind: "Plain Text", modified: now.addingTimeInterval(-15 * 86_400), isHidden: true),
        ]
        let selectedURL = projectURL.appending(path: "FileBrowserView.swift")
        return Tab(directoryURL: projectURL, items: items, selectedItemIDs: [selectedURL])
    }

    static func otherTabs() -> [Tab] {
        let home = URL(fileURLWithPath: NSHomeDirectory())
        return [
            Tab(directoryURL: home.appending(path: "Downloads"), items: [], selectedItemIDs: []),
            Tab(directoryURL: home.appending(path: "Projects/blog/posts"), items: [], selectedItemIDs: []),
        ]
    }

    static func ungroupedFavorites() -> [FavoriteItem] {
        let home = URL(fileURLWithPath: NSHomeDirectory())
        return ["Desktop", "Downloads", "Documents"].map { FavoriteItem(url: home.appending(path: $0)) }
    }

    static func favoriteGroups() -> [FavoriteGroup] {
        let projects = URL(fileURLWithPath: NSHomeDirectory()).appending(path: "Projects")
        return [
            FavoriteGroup(
                name: "Dev",
                color: .blue,
                items: ["filebox", "blog", "dotfiles"].map { FavoriteItem(url: projects.appending(path: $0)) },
                isCollapsed: false
            ),
            FavoriteGroup(
                name: "Clients",
                color: .orange,
                items: ["acme", "globex"].map { FavoriteItem(url: projects.appending(path: $0)) },
                isCollapsed: true
            ),
            FavoriteGroup(
                name: "Personal",
                color: .purple,
                items: ["notes", "photos"].map { FavoriteItem(url: projects.appending(path: $0)) },
                isCollapsed: true
            ),
        ]
    }

    static func locations() -> [StorageLocation] {
        [
            StorageLocation(name: "Macintosh HD", systemImageName: "internaldrive", availableCapacity: 184_000_000_000),
            StorageLocation(name: "iCloud Drive", systemImageName: "icloud", availableCapacity: nil),
        ]
    }

    static let previewCode = """
    // Main list for one tab
    struct FileBrowserView: View {
        @State private var model: BrowserModel
        @State private var selection = Set<FileItem.ID>()
        let rowHeight: CGFloat = 28

        var body: some View {
            FileTableView(items: model.items,
                          selection: $selection)
                .onKeyPress(.space) {
                    model.quickLook(selection)
                    return .handled
                }
                .navigationTitle("Sources")
        }
    }
    """

    private static func folder(_ name: String, modified: Date, isHidden: Bool = false) -> FileItem {
        FileItem(
            url: projectURL.appending(path: name, directoryHint: .isDirectory),
            name: name,
            isDirectory: true,
            size: nil,
            dateModified: modified,
            kind: "Folder",
            isHidden: isHidden,
            isSymbolicLink: false
        )
    }

    private static func file(_ name: String, size: Int64, kind: String, modified: Date, isHidden: Bool = false) -> FileItem {
        FileItem(
            url: projectURL.appending(path: name),
            name: name,
            isDirectory: false,
            size: size,
            dateModified: modified,
            kind: kind,
            isHidden: isHidden,
            isSymbolicLink: false
        )
    }
}
