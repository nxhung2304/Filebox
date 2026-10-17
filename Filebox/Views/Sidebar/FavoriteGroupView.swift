import SwiftUI

struct FavoriteGroupView: View {
    static let colorDotSize: CGFloat = 8
    static let chevronSize: CGFloat = 10
    static let collapseAnimationDuration = 0.15

    let group: FavoriteGroup

    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            header
            if !group.isCollapsed {
                ForEach(group.items) { favorite in
                    FavoriteRow(
                        title: favorite.name,
                        systemImageName: "folder",
                        iconColor: groupColor,
                        isCurrent: isCurrentDirectoryInside(favorite.url),
                        leadingIndent: SidebarRowMetrics.groupItemIndent
                    )
                }
            }
        }
        .padding(.top, 6)
    }

    private var header: some View {
        Button {
            withAnimation(.easeInOut(duration: Self.collapseAnimationDuration)) {
                appState.toggleGroupCollapsed(group.id)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "chevron.right")
                    .font(.system(size: Self.chevronSize, weight: .bold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(group.isCollapsed ? 0 : 90))
                    .accessibilityHidden(true)
                Circle()
                    .fill(groupColor)
                    .frame(width: Self.colorDotSize, height: Self.colorDotSize)
                    .accessibilityHidden(true)
                Text(group.name)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text("\(group.items.count)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, SidebarRowMetrics.horizontalPadding)
            .frame(height: SidebarRowMetrics.height)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(group.name), \(group.items.count) items")
    }

    private var groupColor: Color { Color(group.color.assetName) }

    private func isCurrentDirectoryInside(_ favoriteURL: URL) -> Bool {
        let favoriteComponents = favoriteURL.standardizedFileURL.pathComponents
        let currentComponents = appState.currentDirectoryURL.standardizedFileURL.pathComponents
        return currentComponents.starts(with: favoriteComponents)
    }
}
