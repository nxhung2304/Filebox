import Foundation

struct PanelState: Identifiable, Sendable {
    let id = UUID()
    var tabs: [Tab]
    var activeTabIndex: Int

    var activeTab: Tab { tabs[activeTabIndex] }
}
