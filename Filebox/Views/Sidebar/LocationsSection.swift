import SwiftUI

struct LocationsSection: View {
    static let topSpacing: CGFloat = 10

    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            SidebarSectionHeader(title: "Locations")
            ForEach(appState.locations) { location in
                HStack(spacing: 8) {
                    Image(systemName: location.systemImageName)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text(location.name)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if let capacity = location.availableCapacity {
                        Text("\(DisplayFormatter.sizeText(for: capacity)) available")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .font(.system(size: 13))
                .padding(.horizontal, SidebarRowMetrics.horizontalPadding)
                .frame(height: SidebarRowMetrics.height)
            }
        }
        .padding(.top, Self.topSpacing)
    }
}
