import SwiftUI

struct FavoriteRow: View {
    let title: String
    let systemImageName: String
    var iconColor: Color = .accentColor
    var isCurrent = false
    var leadingIndent: CGFloat = 0

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImageName)
                .foregroundStyle(iconColor)
                .accessibilityHidden(true)
            Text(title)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
        }
        .font(.system(size: 13))
        .padding(.leading, SidebarRowMetrics.horizontalPadding + leadingIndent)
        .padding(.trailing, SidebarRowMetrics.horizontalPadding)
        .frame(height: SidebarRowMetrics.height)
        .background(
            isCurrent ? Color(nsColor: .unemphasizedSelectedContentBackgroundColor) : .clear,
            in: RoundedRectangle(cornerRadius: SidebarRowMetrics.cornerRadius)
        )
    }
}
