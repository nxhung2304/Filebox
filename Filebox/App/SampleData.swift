import Foundation

enum SampleData {
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
}
