import SwiftUI

struct PanelView: View {
    let panelIndex: Int

    @Environment(AppState.self) private var appState

    var body: some View {
        let panel = appState.panels[panelIndex]
        VStack(spacing: 0) {
            TabBar(panelIndex: panelIndex)
            FileTableView(
                items: panel.activeTab.items,
                selectedItemIDs: panel.activeTab.selectedItemIDs,
                onSelectionChange: { appState.updateSelection($0, inPanelAt: panelIndex) }
            )
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}
