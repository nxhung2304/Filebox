import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    static let loadingIndicatorDelay = Duration.milliseconds(150)

    var panels: [PanelState]
    var focusedPanelIndex = 0
    var isPreviewVisible = true
    var showsHiddenFiles = false
    var isShowingGoToFolder = false
    var currentVolumeAvailableCapacity: Int64?
    var ungroupedFavorites: [FavoriteItem]
    var favoriteGroups: [FavoriteGroup]
    var locations: [StorageLocation]

    private let fileSystemService = FileSystemService()
    @ObservationIgnored private var hasPendingReload = false
    @ObservationIgnored private lazy var directoryWatcher = DirectoryWatcher { [weak self] in
        self?.reloadFocusedDirectory()
    }

    init(startDirectoryURL: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)) {
        panels = [PanelState(tabs: [Tab(directoryURL: startDirectoryURL)], activeTabIndex: 0)]
        ungroupedFavorites = SampleData.ungroupedFavorites()
        favoriteGroups = SampleData.favoriteGroups()
        locations = SampleData.locations()
        loadActiveDirectory(inPanelAt: 0)
    }

    var focusedPanel: PanelState { panels[focusedPanelIndex] }

    var focusedTab: Tab { focusedPanel.activeTab }

    var currentDirectoryURL: URL { focusedTab.directoryURL }

    func visibleItems(in tab: Tab) -> [FileItem] {
        showsHiddenFiles ? tab.items : tab.items.filter { !$0.isHidden }
    }

    var selectedItem: FileItem? {
        let tab = focusedTab
        guard tab.selectedItemIDs.count == 1 else { return nil }
        return visibleItems(in: tab).first { tab.selectedItemIDs.contains($0.id) }
    }

    func selectedItems(inPanelAt panelIndex: Int) -> [FileItem] {
        let tab = panels[panelIndex].activeTab
        return visibleItems(in: tab).filter { tab.selectedItemIDs.contains($0.id) }
    }

    func selectTab(at index: Int, inPanelAt panelIndex: Int) {
        panels[panelIndex].activeTabIndex = index
        focusedPanelIndex = panelIndex
        watchFocusedDirectory()
    }

    func updateSelection(_ selectedItemIDs: Set<FileItem.ID>, inPanelAt panelIndex: Int) {
        updateActiveTab(inPanelAt: panelIndex) { $0.selectedItemIDs = selectedItemIDs }
    }

    func toggleGroupCollapsed(_ groupID: FavoriteGroup.ID) {
        guard let index = favoriteGroups.firstIndex(where: { $0.id == groupID }) else { return }
        favoriteGroups[index].isCollapsed.toggle()
    }

    func navigate(to directoryURL: URL, selecting itemURL: URL? = nil) {
        let isCurrentDirectory = directoryURL.normalizedFilePath == currentDirectoryURL.normalizedFilePath
        guard !isCurrentDirectory || itemURL != nil else { return }
        updateActiveTab(inPanelAt: focusedPanelIndex) { tab in
            tab.recordNavigation(to: directoryURL)
            tab.selectedItemIDs = itemURL.map { [$0.normalizedFilePath] } ?? []
        }
        loadActiveDirectory(inPanelAt: focusedPanelIndex)
    }

    func goBack() {
        let previousDirectoryURL = currentDirectoryURL
        var didMove = false
        updateActiveTab(inPanelAt: focusedPanelIndex) { didMove = $0.goBack() }
        guard didMove else { return }
        selectItemIfChild(previousDirectoryURL)
        loadActiveDirectory(inPanelAt: focusedPanelIndex)
    }

    func goForward() {
        let previousDirectoryURL = currentDirectoryURL
        var didMove = false
        updateActiveTab(inPanelAt: focusedPanelIndex) { didMove = $0.goForward() }
        guard didMove else { return }
        selectItemIfChild(previousDirectoryURL)
        loadActiveDirectory(inPanelAt: focusedPanelIndex)
    }

    var canGoToEnclosingFolder: Bool { currentDirectoryURL.normalizedFilePath != "/" }

    func goToEnclosingFolder() {
        guard canGoToEnclosingFolder else { return }
        navigate(to: currentDirectoryURL.deletingLastPathComponent(), selecting: currentDirectoryURL)
    }

    func openSelectedItems() {
        open(selectedItems(inPanelAt: focusedPanelIndex))
    }

    func open(_ items: [FileItem]) {
        if items.count == 1, let item = items.first, item.isDirectory {
            navigate(to: item.url)
            return
        }
        for item in items where !item.isDirectory {
            if item.isAlias {
                openAlias(item)
            } else {
                NSWorkspace.shared.open(item.url)
            }
        }
    }

    func setSort(column: FileSortColumn, ascending: Bool, inPanelAt panelIndex: Int) {
        let tab = panels[panelIndex].activeTab
        guard tab.sortColumn != column || tab.isSortAscending != ascending else { return }
        updateActiveTab(inPanelAt: panelIndex) { tab in
            tab.sortColumn = column
            tab.isSortAscending = ascending
            tab.items = FileItemSorter.sorted(tab.items, by: column, ascending: ascending)
        }
    }

    func toggleHiddenFiles() {
        showsHiddenFiles.toggle()
    }

    func goToFolder(atPath path: String) async -> Bool {
        let url = URL(fileURLWithPath: PathCompletionService().expandedPath(path))
        if await fileSystemService.isDirectory(at: url) {
            navigate(to: url)
            return true
        }
        guard await fileSystemService.itemExists(at: url) else { return false }
        navigate(to: url.deletingLastPathComponent(), selecting: url)
        return true
    }

    private func openAlias(_ item: FileItem) {
        Task {
            guard let resolvedURL = await fileSystemService.resolveAlias(at: item.url) else {
                NSWorkspace.shared.open(item.url)
                return
            }
            if await fileSystemService.isDirectory(at: resolvedURL) {
                navigate(to: resolvedURL)
            } else {
                NSWorkspace.shared.open(resolvedURL)
            }
        }
    }

    private func selectItemIfChild(_ previousDirectoryURL: URL) {
        let previousParentPath = previousDirectoryURL.deletingLastPathComponent().normalizedFilePath
        updateActiveTab(inPanelAt: focusedPanelIndex) { tab in
            let isChild = previousParentPath == tab.directoryURL.normalizedFilePath
            tab.selectedItemIDs = isChild ? [previousDirectoryURL.normalizedFilePath] : []
        }
    }

    private func reloadFocusedDirectory() {
        guard !focusedTab.isLoading else {
            hasPendingReload = true
            return
        }
        loadActiveDirectory(inPanelAt: focusedPanelIndex)
    }

    private func loadActiveDirectory(inPanelAt panelIndex: Int) {
        let loadID = UUID()
        let tab = panels[panelIndex].activeTab
        let tabID = tab.id
        let directoryURL = tab.directoryURL
        updateActiveTab(inPanelAt: panelIndex) { tab in
            tab.loadID = loadID
            tab.isLoading = true
        }
        if panelIndex == focusedPanelIndex {
            watchFocusedDirectory()
        }

        Task {
            try? await Task.sleep(for: Self.loadingIndicatorDelay)
            updateTab(tabID, inPanelAt: panelIndex, ifLoadIDMatches: loadID) { tab in
                tab.isShowingLoadingIndicator = tab.isLoading
            }
        }

        Task {
            async let capacityResult = fileSystemService.availableCapacity(forVolumeContaining: directoryURL)
            let loadedSortColumn = tab.sortColumn
            let loadedSortAscending = tab.isSortAscending
            let sortedResult = await fileSystemService.loadDirectory(
                at: directoryURL,
                sortedBy: loadedSortColumn,
                ascending: loadedSortAscending
            )
            let capacity = await capacityResult
            updateTab(tabID, inPanelAt: panelIndex, ifLoadIDMatches: loadID) { tab in
                tab.isLoading = false
                tab.isShowingLoadingIndicator = false
                if panelIndex == focusedPanelIndex {
                    currentVolumeAvailableCapacity = capacity
                }
                switch sortedResult {
                case .success(let loadedItems):
                    let isSortUnchanged = tab.sortColumn == loadedSortColumn && tab.isSortAscending == loadedSortAscending
                    let items = isSortUnchanged
                        ? loadedItems
                        : FileItemSorter.sorted(loadedItems, by: tab.sortColumn, ascending: tab.isSortAscending)
                    let existingIDs = Set(items.map(\.id))
                    tab.items = items
                    tab.selectedItemIDs.formIntersection(existingIDs)
                    tab.loadError = nil
                case .failure(let error):
                    tab.items = []
                    tab.selectedItemIDs = []
                    tab.loadError = error
                }
            }
            if hasPendingReload, panelIndex == focusedPanelIndex {
                hasPendingReload = false
                reloadFocusedDirectory()
            }
        }
    }

    private func watchFocusedDirectory() {
        directoryWatcher.watch(currentDirectoryURL)
    }

    private func updateActiveTab(inPanelAt panelIndex: Int, _ update: (inout Tab) -> Void) {
        let tabIndex = panels[panelIndex].activeTabIndex
        update(&panels[panelIndex].tabs[tabIndex])
    }

    private func updateTab(
        _ tabID: Tab.ID,
        inPanelAt panelIndex: Int,
        ifLoadIDMatches loadID: UUID,
        _ update: (inout Tab) -> Void
    ) {
        guard let tabIndex = panels[panelIndex].tabs.firstIndex(where: { $0.id == tabID }),
              panels[panelIndex].tabs[tabIndex].loadID == loadID else {
            return
        }
        update(&panels[panelIndex].tabs[tabIndex])
    }
}
