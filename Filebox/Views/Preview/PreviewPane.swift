import SwiftUI

struct PreviewPane: View {
    static let sectionSpacing: CGFloat = 14
    static let padding: CGFloat = 16
    static let iconSize: CGFloat = 32

    @Environment(AppState.self) private var appState
    @Environment(\.controlActiveState) private var controlActiveState

    var body: some View {
        VStack(alignment: .leading, spacing: Self.sectionSpacing) {
            if let item = appState.selectedItem {
                header(
                    icon: FileIcon.image(for: item),
                    title: item.name,
                    subtitle: item.size == nil ? item.kind : "\(item.kind) · \(DisplayFormatter.sizeText(for: item.size))"
                )
                InfoList(url: item.url, dateModified: item.dateModified)
            } else {
                header(
                    icon: FileIcon.folderImage,
                    title: appState.focusedTab.title,
                    subtitle: currentFolderSummary
                )
                InfoList(url: appState.currentDirectoryURL, dateModified: nil)
            }
            actionButtons
            Spacer(minLength: 0)
        }
        .padding(Self.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var currentFolderSummary: String {
        let itemCount = appState.visibleItems(in: appState.focusedTab).count
        return "Folder · \(itemCount) \(itemCount == 1 ? "item" : "items")"
    }

    private func header(icon: NSImage, title: String, subtitle: String) -> some View {
        HStack(spacing: 10) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: Self.iconSize, height: Self.iconSize)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var actionButtons: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) {
                openInEditorButton
                copyPathButton
                openInTerminalButton
                agentButton
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    openInEditorButton
                    copyPathButton
                    openInTerminalButton
                }
                agentButton
            }
        }
    }

    @ViewBuilder
    private var openInEditorButton: some View {
        if controlActiveState == .inactive {
            Button("Open in Editor") {}
                .buttonStyle(.bordered)
        } else {
            Button("Open in Editor") {}
                .buttonStyle(.borderedProminent)
        }
    }

    private var copyPathButton: some View {
        Button("Copy Path", systemImage: "doc.on.doc") {}
            .labelStyle(.iconOnly)
            .help("Copy Path (⌘⌥C)")
    }

    private var openInTerminalButton: some View {
        Button("Open in Terminal", systemImage: "terminal") {}
            .labelStyle(.iconOnly)
            .help("Open in Terminal (⌘⌥T)")
    }

    private var agentButton: some View {
        Menu {
            Button("Claude Code") {}
            Button("Codex") {}
            Button("Gemini CLI") {}
        } label: {
            Label("Claude Code", systemImage: "apple.terminal")
        } primaryAction: {
        }
        .fixedSize()
        .help("Open Claude Code Here (⌘⇧A)")
        .accessibilityLabel("Open Claude Code Here")
    }
}
