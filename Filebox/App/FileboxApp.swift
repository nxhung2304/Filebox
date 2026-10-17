import SwiftUI

@main
struct FileboxApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environment(appState)
        }
        .defaultSize(width: MainWindow.defaultWidth, height: MainWindow.defaultHeight)
        .windowToolbarStyle(.unified)
    }
}
