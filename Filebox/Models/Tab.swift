import Foundation

struct Tab: Identifiable, Sendable {
    let id = UUID()
    var directoryURL: URL
    var items: [FileItem] = []
    var selectedItemIDs: Set<FileItem.ID> = []
    var backHistory: [URL] = []
    var forwardHistory: [URL] = []
    var sortColumn = FileSortColumn.name
    var isSortAscending = true
    var loadID = UUID()
    var isLoading = false
    var isShowingLoadingIndicator = false
    var loadError: DirectoryLoadError?

    var title: String {
        directoryURL.normalizedFilePath == "/" ? "/" : directoryURL.lastPathComponent
    }

    var canGoBack: Bool { !backHistory.isEmpty }
    var canGoForward: Bool { !forwardHistory.isEmpty }

    mutating func recordNavigation(to url: URL) {
        guard url.normalizedFilePath != directoryURL.normalizedFilePath else { return }
        backHistory.append(directoryURL)
        forwardHistory.removeAll()
        directoryURL = url
    }

    mutating func goBack() -> Bool {
        guard let previousURL = backHistory.popLast() else { return false }
        forwardHistory.append(directoryURL)
        directoryURL = previousURL
        return true
    }

    mutating func goForward() -> Bool {
        guard let nextURL = forwardHistory.popLast() else { return false }
        backHistory.append(directoryURL)
        directoryURL = nextURL
        return true
    }
}
