import SwiftUI

struct MainToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            NavigationButtons()
        }
        ToolbarItem(placement: .navigation) {
            LoadingIndicator()
        }
        ToolbarItem(placement: .primaryAction) {
            ViewStylePicker()
        }
        ToolbarItem(placement: .primaryAction) {
            Button("Toggle Dual Pane", systemImage: "rectangle.split.2x1") {}
        }
        ToolbarItem(placement: .primaryAction) {
            PreviewToggleButton()
        }
    }
}

private struct NavigationButtons: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: 2) {
            Button("Back", systemImage: "chevron.left") { appState.goBack() }
                .disabled(!appState.focusedTab.canGoBack)
            Button("Forward", systemImage: "chevron.right") { appState.goForward() }
                .disabled(!appState.focusedTab.canGoForward)
        }
        .labelStyle(.iconOnly)
    }
}

private struct PreviewToggleButton: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Button(appState.isPreviewVisible ? "Hide Preview" : "Show Preview", systemImage: "sidebar.trailing") {
            appState.isPreviewVisible.toggle()
        }
        .keyboardShortcut("p", modifiers: [.command, .shift])
        .help(appState.isPreviewVisible ? "Hide Preview (⌘⇧P)" : "Show Preview (⌘⇧P)")
    }
}

private struct LoadingIndicator: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.focusedTab.isShowingLoadingIndicator {
            ProgressView()
                .controlSize(.small)
                .accessibilityLabel("Loading")
        }
    }
}

private struct ViewStylePicker: View {
    enum ViewStyle: String, CaseIterable, Identifiable {
        case list = "List"
        case columns = "Columns"
        case icons = "Icons"

        var id: Self { self }

        var systemImageName: String {
            switch self {
            case .list: "list.bullet"
            case .columns: "rectangle.split.3x1"
            case .icons: "square.grid.2x2"
            }
        }
    }

    @State private var selectedStyle = ViewStyle.list

    var body: some View {
        Picker("View Style", selection: $selectedStyle) {
            ForEach(ViewStyle.allCases) { style in
                Label(style.rawValue, systemImage: style.systemImageName)
                    .labelStyle(.iconOnly)
                    .tag(style)
                    .selectionDisabled(style != .list)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("View Style")
    }
}
