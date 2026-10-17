import Foundation

enum GroupColor: String, CaseIterable, Sendable {
    case blue = "Blue"
    case orange = "Orange"
    case purple = "Purple"
    case green = "Green"
    case red = "Red"
    case pink = "Pink"
    case teal = "Teal"
    case gray = "Gray"

    var assetName: String { "GroupColors/\(rawValue)" }
}

struct FavoriteItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    var url: URL

    var name: String { url.lastPathComponent }
}

struct FavoriteGroup: Identifiable, Sendable {
    let id = UUID()
    var name: String
    var color: GroupColor
    var items: [FavoriteItem]
    var isCollapsed: Bool
}

struct StorageLocation: Identifiable, Sendable {
    let id = UUID()
    var name: String
    var systemImageName: String
    var availableCapacity: Int64?
}
