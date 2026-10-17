import SwiftUI

struct StatusBar: View {
    static let height: CGFloat = 24
    static let itemSpacing: CGFloat = 18
    static let horizontalPadding: CGFloat = 16

    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: Self.itemSpacing) {
            Text(selectionSummary)
            Text("Hidden files: \(appState.showsHiddenFiles ? "shown" : "hidden") (⌘⇧.)")
            Spacer()
            if let capacity = appState.bootVolumeAvailableCapacity {
                Text("\(DisplayFormatter.sizeText(for: capacity)) available")
            }
        }
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
        .padding(.horizontal, Self.horizontalPadding)
        .frame(height: Self.height)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var selectionSummary: String {
        let tab = appState.focusedPanel.activeTab
        let itemCount = tab.items.count
        let itemWord = itemCount == 1 ? "item" : "items"
        return "\(itemCount) \(itemWord), \(tab.selectedItemIDs.count) selected"
    }
}
