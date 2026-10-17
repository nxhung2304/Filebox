import AppKit
import SwiftUI

struct FileTableView: NSViewRepresentable {
    static let rowHeight: CGFloat = 28
    static let headerHeight: CGFloat = 26

    let items: [FileItem]
    let selectedItemIDs: Set<FileItem.ID>
    let sortColumn: FileSortColumn
    let isSortAscending: Bool
    let onSelectionChange: (Set<FileItem.ID>) -> Void
    let onOpen: ([FileItem]) -> Void
    let onSortChange: (FileSortColumn, Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSScrollView {
        let tableView = FileNSTableView()
        tableView.style = .fullWidth
        tableView.rowHeight = Self.rowHeight
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsMultipleSelection = true
        tableView.allowsColumnReordering = false
        tableView.allowsTypeSelect = true
        tableView.intercellSpacing = NSSize(width: 12, height: 0)
        tableView.headerView = FileTableHeaderView(
            frame: NSRect(x: 0, y: 0, width: 0, height: Self.headerHeight)
        )
        for column in FileTableColumn.allCases {
            tableView.addTableColumn(column.makeTableColumn())
        }
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.target = context.coordinator
        tableView.doubleAction = #selector(Coordinator.openClickedRow(_:))
        tableView.onOpenSelection = { [weak coordinator = context.coordinator] tableView in
            coordinator?.openSelectedRows(in: tableView)
        }

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
        coordinator.onOpen = onOpen
        coordinator.onSortChange = onSortChange
        coordinator.isApplyingState = true
        defer { coordinator.isApplyingState = false }

        let sortDescriptor = NSSortDescriptor(key: FileTableColumn(sortColumn: sortColumn).rawValue, ascending: isSortAscending)
        if tableView.sortDescriptors != [sortDescriptor] {
            tableView.sortDescriptors = [sortDescriptor]
        }
        if coordinator.items != items {
            coordinator.items = items
            tableView.reloadData()
        }
        let selectedRows = IndexSet(items.indices.filter { selectedItemIDs.contains(items[$0].id) })
        if tableView.selectedRowIndexes != selectedRows {
            tableView.selectRowIndexes(selectedRows, byExtendingSelection: false)
        }
        if coordinator.lastAppliedSelectedItemIDs != selectedItemIDs {
            coordinator.lastAppliedSelectedItemIDs = selectedItemIDs
            if let firstSelectedRow = selectedRows.first {
                tableView.scrollRowToVisible(firstSelectedRow)
            }
        }
    }

    @MainActor
    final class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        var items: [FileItem] = []
        var onSelectionChange: (Set<FileItem.ID>) -> Void = { _ in }
        var onOpen: ([FileItem]) -> Void = { _ in }
        var onSortChange: (FileSortColumn, Bool) -> Void = { _, _ in }
        var isApplyingState = false
        var lastAppliedSelectedItemIDs: Set<FileItem.ID> = []

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

        func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
            tableColumn?.identifier.rawValue == FileTableColumn.name.rawValue ? items[row].name : nil
        }

        func tableViewSelectionDidChange(_ notification: Notification) {
            guard !isApplyingState, let tableView = notification.object as? NSTableView else { return }
            let selectedIDs = Set(tableView.selectedRowIndexes.map { items[$0].id })
            lastAppliedSelectedItemIDs = selectedIDs
            onSelectionChange(selectedIDs)
        }

        func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
            guard !isApplyingState,
                  let sortDescriptor = tableView.sortDescriptors.first,
                  let key = sortDescriptor.key,
                  let column = FileTableColumn(rawValue: key) else {
                return
            }
            onSortChange(column.sortColumn, sortDescriptor.ascending)
        }

        @objc func openClickedRow(_ sender: NSTableView) {
            guard sender.clickedRow >= 0 else { return }
            onOpen([items[sender.clickedRow]])
        }

        func openSelectedRows(in tableView: NSTableView) {
            let selectedItems = tableView.selectedRowIndexes.map { items[$0] }
            guard !selectedItems.isEmpty else { return }
            onOpen(selectedItems)
        }
    }
}

final class FileNSTableView: NSTableView {
    private static let returnKeyCode: UInt16 = 36
    private static let keypadEnterKeyCode: UInt16 = 76

    var onOpenSelection: ((NSTableView) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        let isOpenKey = event.keyCode == Self.returnKeyCode || event.keyCode == Self.keypadEnterKeyCode
        if isOpenKey, event.modifierFlags.intersection(.deviceIndependentFlagsMask).isEmpty {
            onOpenSelection?(self)
            return
        }
        super.keyDown(with: event)
    }
}

enum FileTableColumn: String, CaseIterable {
    case name = "Name"
    case dateModified = "Date Modified"
    case size = "Size"
    case kind = "Kind"

    private static let totalWidthUnit: CGFloat = 70

    init(sortColumn: FileSortColumn) {
        switch sortColumn {
        case .name: self = .name
        case .dateModified: self = .dateModified
        case .size: self = .size
        case .kind: self = .kind
        }
    }

    var sortColumn: FileSortColumn {
        switch self {
        case .name: .name
        case .dateModified: .dateModified
        case .size: .size
        case .kind: .kind
        }
    }

    private var relativeWidth: CGFloat {
        switch self {
        case .name: 3
        case .dateModified: 1.6
        case .size: 1
        case .kind: 1
        }
    }

    private var defaultSortsAscending: Bool {
        switch self {
        case .name, .kind: true
        case .dateModified, .size: false
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
        column.sortDescriptorPrototype = NSSortDescriptor(key: rawValue, ascending: defaultSortsAscending)
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
