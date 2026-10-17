import AppKit
import SwiftUI

struct FileTableView: NSViewRepresentable {
    static let rowHeight: CGFloat = 28
    static let headerHeight: CGFloat = 26

    let items: [FileItem]
    let selectedItemIDs: Set<FileItem.ID>
    let onSelectionChange: (Set<FileItem.ID>) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelectionChange: onSelectionChange)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let tableView = NSTableView()
        tableView.style = .fullWidth
        tableView.rowHeight = Self.rowHeight
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsMultipleSelection = true
        tableView.allowsColumnReordering = false
        tableView.intercellSpacing = NSSize(width: 12, height: 0)
        tableView.headerView = FileTableHeaderView(
            frame: NSRect(x: 0, y: 0, width: 0, height: Self.headerHeight)
        )
        for column in FileTableColumn.allCases {
            tableView.addTableColumn(column.makeTableColumn())
        }
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator

        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let tableView = scrollView.documentView as? NSTableView else { return }
        let coordinator = context.coordinator
        coordinator.onSelectionChange = onSelectionChange
        if coordinator.items != items {
            coordinator.items = items
            tableView.reloadData()
        }
        let selectedRows = IndexSet(items.indices.filter { selectedItemIDs.contains(items[$0].id) })
        if tableView.selectedRowIndexes != selectedRows {
            coordinator.isApplyingSelection = true
            tableView.selectRowIndexes(selectedRows, byExtendingSelection: false)
            coordinator.isApplyingSelection = false
        }
    }

    @MainActor
    final class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        var items: [FileItem] = []
        var onSelectionChange: (Set<FileItem.ID>) -> Void
        var isApplyingSelection = false

        init(onSelectionChange: @escaping (Set<FileItem.ID>) -> Void) {
            self.onSelectionChange = onSelectionChange
        }

        func numberOfRows(in tableView: NSTableView) -> Int {
            items.count
        }

        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard let tableColumn, let column = FileTableColumn(rawValue: tableColumn.identifier.rawValue) else {
                return nil
            }
            let cell = tableView.makeView(withIdentifier: tableColumn.identifier, owner: nil) as? FileRowCell
                ?? FileRowCell(column: column)
            cell.identifier = tableColumn.identifier
            cell.configure(with: items[row])
            return cell
        }

        func tableViewSelectionDidChange(_ notification: Notification) {
            guard !isApplyingSelection, let tableView = notification.object as? NSTableView else { return }
            let selectedIDs = Set(tableView.selectedRowIndexes.map { items[$0].id })
            onSelectionChange(selectedIDs)
        }
    }
}

enum FileTableColumn: String, CaseIterable {
    case name = "Name"
    case dateModified = "Date Modified"
    case size = "Size"
    case kind = "Kind"

    private static let totalWidthUnit: CGFloat = 70

    private var relativeWidth: CGFloat {
        switch self {
        case .name: 3
        case .dateModified: 1.6
        case .size: 1
        case .kind: 1
        }
    }

    var isRightAligned: Bool { self == .size }

    @MainActor
    func makeTableColumn() -> NSTableColumn {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue))
        column.title = rawValue
        column.width = relativeWidth * Self.totalWidthUnit
        column.resizingMask = [.autoresizingMask, .userResizingMask]
        column.headerCell = FileTableHeaderCell(textCell: rawValue)
        column.headerCell.alignment = isRightAligned ? .right : .left
        return column
    }
}

final class FileTableHeaderView: NSTableHeaderView {
    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: FileTableView.headerHeight)
    }
}

final class FileTableHeaderCell: NSTableHeaderCell {
    override init(textCell string: String) {
        super.init(textCell: string)
        font = .systemFont(ofSize: 11, weight: .semibold)
        textColor = .secondaryLabelColor
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
