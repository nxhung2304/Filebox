import Foundation

enum DirectoryLoadError: Error, Equatable, Sendable {
    case permissionDenied
    case notFound
    case other(String)
}
