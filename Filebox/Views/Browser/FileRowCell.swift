import AppKit

final class FileRowCell: NSTableCellView {
    private static let iconSize: CGFloat = 16
    private static let iconTextSpacing: CGFloat = 8
    private static let hiddenIconAlpha: CGFloat = 0.5

    private let column: FileTableColumn
    private let label = NSTextField(labelWithString: "")
    private let iconView = NSImageView()

    init(column: FileTableColumn) {
        self.column = column
        super.init(frame: .zero)
        setUpSubviews()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(with item: FileItem) {
        let isSecondaryText = column != .name || item.isHidden
        label.textColor = isSecondaryText ? .secondaryLabelColor : .labelColor
        switch column {
        case .name:
            label.stringValue = item.name
            iconView.image = FileIcon.image(for: item)
            iconView.alphaValue = item.isHidden ? Self.hiddenIconAlpha : 1
        case .dateModified:
            label.stringValue = DisplayFormatter.dateText(for: item.dateModified)
        case .size:
            label.stringValue = DisplayFormatter.sizeText(for: item.size)
        case .kind:
            label.stringValue = item.kind
        }
    }

    private func setUpSubviews() {
        label.font = column == .size
            ? .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
            : .systemFont(ofSize: 13)
        label.lineBreakMode = .byTruncatingTail
        label.alignment = column.isRightAligned ? .right : .left
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        textField = label

        var constraints = [
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
        if column == .name {
            iconView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iconView)
            imageView = iconView
            constraints += [
                iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
                iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: Self.iconSize),
                iconView.heightAnchor.constraint(equalToConstant: Self.iconSize),
                label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: Self.iconTextSpacing),
            ]
        } else {
            constraints.append(label.leadingAnchor.constraint(equalTo: leadingAnchor))
        }
        NSLayoutConstraint.activate(constraints)
    }

}
