import Foundation

struct PathCompletionService: Sendable {
    static let maximumSuggestionCount = 10

    func expandedPath(_ input: String) -> String {
        (input.trimmingCharacters(in: .whitespaces) as NSString).expandingTildeInPath
    }

    func suggestions(for input: String) async -> [String] {
        let expandedInput = expandedPath(input)
        guard expandedInput.hasPrefix("/") else { return [] }
        let endsWithSeparator = input.trimmingCharacters(in: .whitespaces).hasSuffix("/")
        return await Task.detached(priority: .userInitiated) {
            Self.directorySuggestions(for: expandedInput, listsFolderContents: endsWithSeparator)
        }.value
    }

    private static func directorySuggestions(for expandedInput: String, listsFolderContents: Bool) -> [String] {
        let parentPath: String
        let namePrefix: String
        if listsFolderContents {
            parentPath = expandedInput
            namePrefix = ""
        } else {
            parentPath = (expandedInput as NSString).deletingLastPathComponent
            namePrefix = (expandedInput as NSString).lastPathComponent
        }
        let parentURL = URL(fileURLWithPath: parentPath, isDirectory: true)
        let includesHidden = namePrefix.hasPrefix(".")
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: parentURL,
            includingPropertiesForKeys: [.isDirectoryKey, .isPackageKey],
            options: includesHidden ? [] : [.skipsHiddenFiles]
        ) else {
            return []
        }
        let matchingPaths = urls
            .filter { url in
                let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isPackageKey])
                let isDirectory = (values?.isDirectory ?? false) && !(values?.isPackage ?? false)
                return isDirectory && url.lastPathComponent.lowercased().hasPrefix(namePrefix.lowercased())
            }
            .map(\.normalizedFilePath)
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        return Array(matchingPaths.prefix(maximumSuggestionCount))
    }
}
