import Foundation

enum FileItemSorter {
    static func sorted(_ items: [FileItem], by column: FileSortColumn, ascending: Bool) -> [FileItem] {
        items.sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory {
                return lhs.isDirectory
            }
            let order = compare(lhs, rhs, by: column)
            let resolvedOrder = order == .orderedSame ? lhs.name.localizedStandardCompare(rhs.name) : order
            return ascending ? resolvedOrder == .orderedAscending : resolvedOrder == .orderedDescending
        }
    }

    private static func compare(_ lhs: FileItem, _ rhs: FileItem, by column: FileSortColumn) -> ComparisonResult {
        switch column {
        case .name:
            return lhs.name.localizedStandardCompare(rhs.name)
        case .dateModified:
            return compareValues(lhs.dateModified, rhs.dateModified)
        case .size:
            return compareValues(lhs.size ?? -1, rhs.size ?? -1)
        case .kind:
            return lhs.kind.localizedStandardCompare(rhs.kind)
        }
    }

    private static func compareValues<Value: Comparable>(_ lhs: Value, _ rhs: Value) -> ComparisonResult {
        if lhs < rhs { return .orderedAscending }
        if lhs > rhs { return .orderedDescending }
        return .orderedSame
    }
}
