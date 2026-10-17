import SwiftUI

struct Breadcrumb: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(pathSegments.enumerated()), id: \.offset) { index, segment in
                if index > 0 {
                    Text("›")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                let isLastSegment = index == pathSegments.count - 1
                Button(segment) {}
                    .buttonStyle(.plain)
                    .fontWeight(isLastSegment ? .semibold : .regular)
                    .foregroundStyle(isLastSegment ? .primary : .secondary)
            }
        }
        .font(.system(size: 13))
        .lineLimit(1)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Path")
    }

    private var pathSegments: [String] {
        let homeComponents = URL(fileURLWithPath: NSHomeDirectory()).standardizedFileURL.pathComponents
        let pathComponents = appState.currentDirectoryURL.standardizedFileURL.pathComponents
        guard pathComponents.starts(with: homeComponents) else {
            return pathComponents
        }
        return ["~"] + pathComponents.dropFirst(homeComponents.count)
    }
}
