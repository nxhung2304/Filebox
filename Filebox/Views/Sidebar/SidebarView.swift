import SwiftUI

struct SidebarView: View {
    static let horizontalPadding: CGFloat = 10
    static let verticalPadding: CGFloat = 12

    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {
                SidebarSectionHeader(title: "Favorites")
                FavoriteRow(title: "Recents", systemImageName: "clock")
                ForEach(appState.ungroupedFavorites) { favorite in
                    FavoriteRow(title: favorite.name, systemImageName: "folder")
                }
                ForEach(appState.favoriteGroups) { group in
                    FavoriteGroupView(group: group)
                }
                NewGroupButton()
                LocationsSection()
            }
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.vertical, Self.verticalPadding)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct SidebarSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, SidebarRowMetrics.horizontalPadding)
            .padding(.top, 4)
            .padding(.bottom, 6)
    }
}

enum SidebarRowMetrics {
    static let height: CGFloat = 26
    static let horizontalPadding: CGFloat = 8
    static let cornerRadius: CGFloat = 6
    static let groupItemIndent: CGFloat = 10
}

private struct NewGroupButton: View {
    var body: some View {
        Button {
        } label: {
            Label("New Group", systemImage: "plus")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: SidebarRowMetrics.height, alignment: .leading)
                .padding(.horizontal, SidebarRowMetrics.horizontalPadding)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
