import SwiftUI

struct PanelView: View {
    let panelIndex: Int

    @Environment(AppState.self) private var appState

    var body: some View {
        let tab = appState.panels[panelIndex].activeTab
        let visibleItems = appState.visibleItems(in: tab)
        VStack(spacing: 0) {
            if appState.panels[panelIndex].tabs.count > 1 {
                TabBar(panelIndex: panelIndex)
            }
            FileTableView(
                items: visibleItems,
                selectedItemIDs: tab.selectedItemIDs,
                sortColumn: tab.sortColumn,
                isSortAscending: tab.isSortAscending,
                onSelectionChange: { appState.updateSelection($0, inPanelAt: panelIndex) },
                onOpen: { appState.open($0) },
                onSortChange: { appState.setSort(column: $0, ascending: $1, inPanelAt: panelIndex) }
            )
            .overlay {
                if let loadError = tab.loadError {
                    DirectoryErrorView(error: loadError)
                } else if visibleItems.isEmpty && !tab.isLoading {
                    Text("Empty Folder")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

private struct DirectoryErrorView: View {
    static let iconSize: CGFloat = 32

    let error: DirectoryLoadError

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: Self.iconSize))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text(message)
                .font(.system(size: 13, weight: .semibold))
            if let guidance {
                Text(guidance)
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var iconName: String {
        error == .permissionDenied ? "lock" : "exclamationmark.triangle"
    }

    private var message: String {
        switch error {
        case .permissionDenied: "You don't have permission to access this folder"
        case .notFound: "This folder no longer exists"
        case .other(let description): description
        }
    }

    private var guidance: String? {
        error == .permissionDenied
            ? "Give Filebox Full Disk Access in System Settings, then reopen this folder."
            : nil
    }
}
