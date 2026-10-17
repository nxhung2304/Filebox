import SwiftUI

struct Breadcrumb: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ForEach(ancestorURLs, id: \.self) { url in
            Button {
                appState.navigate(to: url)
            } label: {
                Label(title(for: url), systemImage: "folder")
            }
        }
    }

    private var ancestorURLs: [URL] {
        var urls: [URL] = []
        var url = appState.currentDirectoryURL.standardizedFileURL
        while true {
            urls.append(url)
            guard url.normalizedFilePath != "/" else { break }
            url = url.deletingLastPathComponent()
        }
        return urls
    }

    private func title(for url: URL) -> String {
        url.normalizedFilePath == "/" ? "/" : url.lastPathComponent
    }
}
