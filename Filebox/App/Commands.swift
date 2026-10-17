import SwiftUI

struct FileboxCommands: Commands {
    let appState: AppState

    var body: some Commands {
        CommandGroup(before: .toolbar) {
            Button(appState.showsHiddenFiles ? "Hide Hidden Files" : "Show Hidden Files") {
                appState.toggleHiddenFiles()
            }
            .keyboardShortcut(".", modifiers: [.command, .shift])
            Divider()
        }
        CommandMenu("Go") {
            Button("Back") { appState.goBack() }
                .keyboardShortcut("[", modifiers: .command)
                .disabled(!appState.focusedTab.canGoBack)
            Button("Forward") { appState.goForward() }
                .keyboardShortcut("]", modifiers: .command)
                .disabled(!appState.focusedTab.canGoForward)
            Button("Enclosing Folder") { appState.goToEnclosingFolder() }
                .keyboardShortcut(.upArrow, modifiers: .command)
                .disabled(!appState.canGoToEnclosingFolder)
            Button("Open") { appState.openSelectedItems() }
                .keyboardShortcut(.downArrow, modifiers: .command)
                .disabled(appState.selectedItems(inPanelAt: appState.focusedPanelIndex).isEmpty)
            Divider()
            Button("Go to Folder…") { appState.isShowingGoToFolder = true }
                .keyboardShortcut("g", modifiers: [.command, .shift])
        }
    }
}
