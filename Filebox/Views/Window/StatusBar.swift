import SwiftUI

struct StatusBar: View {
    static let height: CGFloat = 24
    static let itemSpacing: CGFloat = 18
    static let horizontalPadding: CGFloat = 16

    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: Self.itemSpacing) {
            Text(selectionSummary)
            Button("Hidden files: \(appState.showsHiddenFiles ? "shown" : "hidden")") {
                appState.toggleHiddenFiles()
            }
            .buttonStyle(.plain)
            .help(appState.showsHiddenFiles ? "Hide Hidden Files (⌘⇧.)" : "Show Hidden Files (⌘⇧.)")
            Spacer()
            if let capacity = appState.currentVolumeAvailableCapacity {
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
        let tab = appState.focusedTab
        let itemCount = appState.visibleItems(in: tab).count
        let itemWord = itemCount == 1 ? "item" : "items"
        return "\(itemCount) \(itemWord), \(appState.selectedItems(inPanelAt: appState.focusedPanelIndex).count) selected"
    }
}
