import SwiftUI

struct MainToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button("Back", systemImage: "chevron.left") {}
            Button("Forward", systemImage: "chevron.right") {}
                .disabled(true)
        }
        ToolbarItem(placement: .navigation) {
            Breadcrumb()
        }
        ToolbarItem(placement: .primaryAction) {
            ViewStylePicker()
        }
        ToolbarItem(placement: .primaryAction) {
            Button("Toggle Dual Pane", systemImage: "rectangle.split.2x1") {}
        }
        ToolbarItem(placement: .primaryAction) {
            ToolbarSearchField()
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

private struct ToolbarSearchField: View {
    static let width: CGFloat = 260
    static let height: CGFloat = 28
    static let cornerRadius: CGFloat = 7
    static let horizontalPadding: CGFloat = 8

    @Environment(AppState.self) private var appState
    @State private var query = ""

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField("Search in \(appState.currentDirectoryURL.lastPathComponent)", text: $query)
                .textFieldStyle(.plain)
                .accessibilityLabel("Search")
            Text("⌘K")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Self.horizontalPadding)
        .frame(width: Self.width, height: Self.height)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: Self.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(Color(nsColor: .separatorColor)))
    }
}
