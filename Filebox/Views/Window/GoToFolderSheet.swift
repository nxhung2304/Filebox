import SwiftUI

struct GoToFolderSheet: View {
    static let width: CGFloat = 480
    static let suggestionListMaximumHeight: CGFloat = 220

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var pathInput = ""
    @State private var suggestions: [String] = []
    @State private var highlightedSuggestionIndex: Int?
    @State private var isShowingNotFound = false
    @FocusState private var isPathFieldFocused: Bool

    private let pathCompletionService = PathCompletionService()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Go to Folder")
                .font(.headline)
            TextField("Enter a path, e.g. ~/Projects", text: $pathInput)
                .font(.system(size: 13, design: .monospaced))
                .textFieldStyle(.roundedBorder)
                .focused($isPathFieldFocused)
                .onKeyPress(.tab) {
                    completeWithHighlightedSuggestion()
                    return .handled
                }
                .onKeyPress(.downArrow) {
                    moveHighlight(by: 1)
                    return .handled
                }
                .onKeyPress(.upArrow) {
                    moveHighlight(by: -1)
                    return .handled
                }
            if !suggestions.isEmpty {
                suggestionList
            }
            if isShowingNotFound {
                Text("The folder can't be found.")
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
            }
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Go", action: goToEnteredPath)
                    .keyboardShortcut(.defaultAction)
                    .disabled(pathInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: Self.width)
        .onAppear { isPathFieldFocused = true }
        .task(id: pathInput) {
            isShowingNotFound = false
            let newSuggestions = await pathCompletionService.suggestions(for: pathInput)
            guard !Task.isCancelled else { return }
            suggestions = newSuggestions
            highlightedSuggestionIndex = newSuggestions.isEmpty ? nil : 0
        }
    }

    private var suggestionList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(suggestions.enumerated()), id: \.element) { index, suggestion in
                    Button {
                        applySuggestion(suggestion)
                    } label: {
                        Text(abbreviatedPath(suggestion))
                            .font(.system(size: 12, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.head)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                index == highlightedSuggestionIndex
                                    ? Color(nsColor: .unemphasizedSelectedContentBackgroundColor)
                                    : .clear,
                                in: RoundedRectangle(cornerRadius: 4)
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxHeight: Self.suggestionListMaximumHeight)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func moveHighlight(by offset: Int) {
        guard !suggestions.isEmpty else { return }
        let currentIndex = highlightedSuggestionIndex ?? -offset
        highlightedSuggestionIndex = min(max(currentIndex + offset, 0), suggestions.count - 1)
    }

    private func completeWithHighlightedSuggestion() {
        guard let highlightedSuggestionIndex, suggestions.indices.contains(highlightedSuggestionIndex) else { return }
        applySuggestion(suggestions[highlightedSuggestionIndex])
    }

    private func applySuggestion(_ suggestion: String) {
        pathInput = abbreviatedPath(suggestion) + "/"
    }

    private func abbreviatedPath(_ path: String) -> String {
        (path as NSString).abbreviatingWithTildeInPath
    }

    private func goToEnteredPath() {
        Task {
            if await appState.goToFolder(atPath: pathInput) {
                dismiss()
            } else {
                isShowingNotFound = true
            }
        }
    }
}
