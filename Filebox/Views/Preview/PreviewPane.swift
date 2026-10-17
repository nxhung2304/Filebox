import SwiftUI

struct PreviewPane: View {
    static let sectionSpacing: CGFloat = 14
    static let padding: CGFloat = 16
    static let iconSize: CGFloat = 32

    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: Self.sectionSpacing) {
            if let item = appState.selectedItem {
                header(for: item)
                CodePreview(text: SampleData.previewCode)
                InfoList(item: item)
                actionButtons
            } else {
                Text("No Selection")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer(minLength: 0)
        }
        .padding(Self.padding)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(nsColor: .underPageBackgroundColor))
    }

    private func header(for item: FileItem) -> some View {
        HStack(spacing: 10) {
            Image(nsImage: FileIcon.image(for: item))
                .resizable()
                .frame(width: Self.iconSize, height: Self.iconSize)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text("\(item.kind) · \(DisplayFormatter.sizeText(for: item.size))")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var actionButtons: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) { buttons }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    openInEditorButton
                    copyPathButton
                }
                HStack(spacing: 8) {
                    openInTerminalButton
                    agentButton
                }
            }
        }
        .controlSize(.large)
    }

    @ViewBuilder
    private var buttons: some View {
        openInEditorButton
        copyPathButton
        openInTerminalButton
        agentButton
    }

    private var openInEditorButton: some View {
        Button("Open in Editor") {}
            .buttonStyle(.borderedProminent)
    }

    private var copyPathButton: some View {
        Button("Copy Path") {}
    }

    private var openInTerminalButton: some View {
        Button("Open in Terminal") {}
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
        .accessibilityLabel("Open Claude Code Here")
    }
}
