import SwiftUI

struct MainWindow: View {
    static let defaultWidth: CGFloat = 1280
    static let defaultHeight: CGFloat = 800
    static let minimumWidth: CGFloat = 860
    static let minimumHeight: CGFloat = 520

    static let sidebarMinimumWidth: CGFloat = 180
    static let sidebarIdealWidth: CGFloat = 220
    static let sidebarMaximumWidth: CGFloat = 320

    static let previewMinimumWidth: CGFloat = 260
    static let previewIdealWidth: CGFloat = 320
    static let previewMaximumWidth: CGFloat = 480

    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            HSplitView {
                SidebarView()
                    .frame(
                        minWidth: Self.sidebarMinimumWidth,
                        idealWidth: Self.sidebarIdealWidth,
                        maxWidth: Self.sidebarMaximumWidth
                    )
                PanelView(panelIndex: 0)
                    .frame(minWidth: Self.minimumWidth - Self.sidebarMinimumWidth - Self.previewMinimumWidth)
                if appState.isPreviewVisible {
                    PreviewPane()
                        .frame(
                            minWidth: Self.previewMinimumWidth,
                            idealWidth: Self.previewIdealWidth,
                            maxWidth: Self.previewMaximumWidth
                        )
                }
            }
            Divider()
            StatusBar()
        }
        .frame(minWidth: Self.minimumWidth, minHeight: Self.minimumHeight)
        .toolbar { MainToolbar() }
    }
}
