import SwiftUI

struct InfoList: View {
    static let labelWidth: CGFloat = 84

    let url: URL
    let dateModified: Date?

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 8, verticalSpacing: 8) {
            if let dateModified {
                GridRow {
                    label("Modified")
                    Text(DisplayFormatter.dateText(for: dateModified))
                }
            }
            GridRow {
                label("Path")
                Text(abbreviatedPath)
                    .font(.system(size: 11, design: .monospaced))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .font(.system(size: 12))
    }

    private func label(_ title: String) -> some View {
        Text(title)
            .foregroundStyle(.secondary)
            .frame(width: Self.labelWidth, alignment: .leading)
    }

    private var abbreviatedPath: String {
        (url.path(percentEncoded: false) as NSString).abbreviatingWithTildeInPath
    }
}
