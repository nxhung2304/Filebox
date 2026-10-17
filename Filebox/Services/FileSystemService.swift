import Foundation
import UniformTypeIdentifiers

struct FileSystemService: Sendable {
    private static let resourceKeys: [URLResourceKey] = [
        .isDirectoryKey,
        .isPackageKey,
        .fileSizeKey,
        .contentModificationDateKey,
        .isHiddenKey,
        .isSymbolicLinkKey,
        .isAliasFileKey,
    ]

    func loadDirectory(
        at directoryURL: URL,
        sortedBy sortColumn: FileSortColumn,
        ascending: Bool
    ) async -> Result<[FileItem], DirectoryLoadError> {
        await Task.detached(priority: .userInitiated) {
            Self.readDirectory(at: directoryURL).map {
                FileItemSorter.sorted($0, by: sortColumn, ascending: ascending)
            }
        }.value
    }

    func availableCapacity(forVolumeContaining url: URL) async -> Int64? {
        await Task.detached(priority: .utility) {
            let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            return values?.volumeAvailableCapacityForImportantUsage
        }.value
    }

    func resolveAlias(at url: URL) async -> URL? {
        await Task.detached(priority: .userInitiated) {
            try? URL(resolvingAliasFileAt: url)
        }.value
    }

    func itemExists(at url: URL) async -> Bool {
        await Task.detached(priority: .userInitiated) {
            FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
        }.value
    }

    func isDirectory(at url: URL) async -> Bool {
        await Task.detached(priority: .userInitiated) {
            Self.isNavigableDirectory(url)
        }.value
    }

    private static func readDirectory(at directoryURL: URL) -> Result<[FileItem], DirectoryLoadError> {
        let urls: [URL]
        do {
            urls = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: resourceKeys,
                options: []
            )
        } catch {
            return .failure(loadError(from: error))
        }
        var kindByExtension: [String: String] = [:]
        let items = urls.compactMap { url in
            makeItem(from: url, kindByExtension: &kindByExtension)
        }
        return .success(items)
    }

    private static func makeItem(from url: URL, kindByExtension: inout [String: String]) -> FileItem? {
        guard let values = try? url.resourceValues(forKeys: Set(resourceKeys)) else { return nil }
        let isSymbolicLink = values.isSymbolicLink ?? false
        let isPackage = values.isPackage ?? false
        let isDirectory = isSymbolicLink
            ? isNavigableDirectory(url.resolvingSymlinksInPath())
            : (values.isDirectory ?? false) && !isPackage
        return FileItem(
            url: url,
            name: url.lastPathComponent,
            isDirectory: isDirectory,
            size: isDirectory || isPackage ? nil : Int64(values.fileSize ?? 0),
            dateModified: values.contentModificationDate ?? .distantPast,
            kind: isDirectory ? "Folder" : kind(forExtension: url.pathExtension, cache: &kindByExtension),
            isHidden: values.isHidden ?? false,
            isSymbolicLink: isSymbolicLink,
            isAlias: !isSymbolicLink && (values.isAliasFile ?? false)
        )
    }

    private static func isNavigableDirectory(_ url: URL) -> Bool {
        let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey])
        return (values?.isDirectory ?? false) && !(values?.isPackage ?? false)
    }

    private static func kind(forExtension pathExtension: String, cache: inout [String: String]) -> String {
        let key = pathExtension.lowercased()
        if let cachedKind = cache[key] { return cachedKind }
        let kind = UTType(filenameExtension: key)?.localizedDescription ?? "Document"
        cache[key] = kind
        return kind
    }

    private static func loadError(from error: Error) -> DirectoryLoadError {
        let nsError = error as NSError
        switch (nsError.domain, nsError.code) {
        case (NSCocoaErrorDomain, NSFileReadNoPermissionError):
            return .permissionDenied
        case (NSCocoaErrorDomain, NSFileReadNoSuchFileError), (NSCocoaErrorDomain, NSFileNoSuchFileError):
            return .notFound
        default:
            if let posixError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError,
               posixError.domain == NSPOSIXErrorDomain,
               posixError.code == Int(EPERM) || posixError.code == Int(EACCES) {
                return .permissionDenied
            }
            return .other(nsError.localizedDescription)
        }
    }
}
