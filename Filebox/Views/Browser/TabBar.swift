import SwiftUI

struct TabBar: View {
    static let height: CGFloat = 34
    static let maximumTabWidth: CGFloat = 200
    static let tabHorizontalPadding: CGFloat = 14

    let panelIndex: Int

    @Environment(AppState.self) private var appState

    var body: some View {
        let panel = appState.panels[panelIndex]
        let isPanelFocused = appState.focusedPanelIndex == panelIndex
        HStack(spacing: 0) {
            ForEach(Array(panel.tabs.enumerated()), id: \.element.id) { index, tab in
                let isActive = index == panel.activeTabIndex
                Button {
                    appState.selectTab(at: index, inPanelAt: panelIndex)
                } label: {
                    Text(tab.title)
                        .lineLimit(1)
                        .fontWeight(isActive && isPanelFocused ? .semibold : .regular)
                        .foregroundStyle(isActive ? .primary : .secondary)
                        .padding(.horizontal, Self.tabHorizontalPadding)
                        .frame(maxWidth: Self.maximumTabWidth, maxHeight: .infinity, alignment: .leading)
                        .background(isActive ? Color(nsColor: .controlBackgroundColor) : .clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Divider()
            }
            Button("New Tab", systemImage: "plus") {}
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
            Spacer(minLength: 0)
        }
        .font(.system(size: 13))
        .frame(height: Self.height)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .bottom) { Divider() }
    }
}
