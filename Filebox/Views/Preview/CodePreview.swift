import SwiftUI

struct CodePreview: View {
    static let maximumHeight: CGFloat = 340
    static let cornerRadius: CGFloat = 8
    static let padding: CGFloat = 12
    static let fontSize: CGFloat = 11.5
    static let lineSpacing: CGFloat = 6

    let text: String

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            Text(text)
                .font(.system(size: Self.fontSize, design: .monospaced))
                .lineSpacing(Self.lineSpacing)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Self.padding)
        }
        .frame(maxHeight: Self.maximumHeight)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: Self.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).strokeBorder(Color(nsColor: .separatorColor)))
    }
}
