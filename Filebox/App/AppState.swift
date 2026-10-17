import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var panels: [PanelState]
    var focusedPanelIndex = 0
    var isPreviewVisible = true
    var showsHiddenFiles = true
    var ungroupedFavorites: [FavoriteItem]
    var favoriteGroups: [FavoriteGroup]
    var locations: [StorageLocation]

    init() {
        let tabs = [SampleData.sourcesTab()] + SampleData.otherTabs()
        panels = [PanelState(tabs: tabs, activeTabIndex: 0)]
        ungroupedFavorites = SampleData.ungroupedFavorites()
        favoriteGroups = SampleData.favoriteGroups()
        locations = SampleData.locations()
    }

    var focusedPanel: PanelState { panels[focusedPanelIndex] }

    var currentDirectoryURL: URL { focusedPanel.activeTab.directoryURL }

    var selectedItem: FileItem? {
        let tab = focusedPanel.activeTab
        guard tab.selectedItemIDs.count == 1 else { return nil }
        return tab.items.first { tab.selectedItemIDs.contains($0.id) }
    }

    var bootVolumeAvailableCapacity: Int64? { locations.first?.availableCapacity }

    func selectTab(at index: Int, inPanelAt panelIndex: Int) {
        panels[panelIndex].activeTabIndex = index
        focusedPanelIndex = panelIndex
    }

    func updateSelection(_ selectedItemIDs: Set<FileItem.ID>, inPanelAt panelIndex: Int) {
        let tabIndex = panels[panelIndex].activeTabIndex
        panels[panelIndex].tabs[tabIndex].selectedItemIDs = selectedItemIDs
    }

    func toggleGroupCollapsed(_ groupID: FavoriteGroup.ID) {
        guard let index = favoriteGroups.firstIndex(where: { $0.id == groupID }) else { return }
        favoriteGroups[index].isCollapsed.toggle()
    }
}
