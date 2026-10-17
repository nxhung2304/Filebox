import AppKit
import UniformTypeIdentifiers

enum FileIcon {
    static func image(for item: FileItem) -> NSImage {
        let contentType = item.isDirectory
            ? UTType.folder
            : UTType(filenameExtension: item.url.pathExtension) ?? .data
        return NSWorkspace.shared.icon(for: contentType)
    }
}
