import Foundation

extension URL {
    var normalizedFilePath: String {
        let path = standardizedFileURL.path(percentEncoded: false)
        guard path.count > 1, path.hasSuffix("/") else { return path }
        return String(path.dropLast())
    }
}
