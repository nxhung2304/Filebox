import SwiftUI

struct MainWindow: View {
    static let defaultWidth: CGFloat = 1280
    static let defaultHeight: CGFloat = 800
    static let minimumWidth: CGFloat = 860
    static let minimumHeight: CGFloat = 520

    static let sidebarMinimumWidth: CGFloat = 180
    static let sidebarIdealWidth: CGFloat = 220
    static let sidebarMaximumWidth: CGFloat = 320

    static let previewMinimumWidth: CGFloat = 220
    static let previewIdealWidth: CGFloat = 260
    static let previewMaximumWidth: CGFloat = 480

    @Environment(AppState.self) private var appState
    @State private var searchQuery = ""

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(
                    min: Self.sidebarMinimumWidth,
                    ideal: Self.sidebarIdealWidth,
                    max: Self.sidebarMaximumWidth
                )
        } detail: {
            VStack(spacing: 0) {
                PanelView(panelIndex: 0)
                Divider()
                StatusBar()
            }
            .inspector(isPresented: Bindable(appState).isPreviewVisible) {
                PreviewPane()
                    .inspectorColumnWidth(
                        min: Self.previewMinimumWidth,
                        ideal: Self.previewIdealWidth,
                        max: Self.previewMaximumWidth
                    )
            }
            .toolbar { MainToolbar() }
            .searchable(text: $searchQuery, placement: .toolbar, prompt: "Search")
            .navigationTitle(appState.focusedTab.title)
            .toolbarTitleMenu { Breadcrumb() }
        }
        .frame(minWidth: Self.minimumWidth, minHeight: Self.minimumHeight)
        .sheet(isPresented: Bindable(appState).isShowingGoToFolder) {
            GoToFolderSheet()
        }
    }
}
