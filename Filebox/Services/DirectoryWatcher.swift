import CoreServices
import Foundation

@MainActor
final class DirectoryWatcher {
    private static let eventLatency: CFTimeInterval = 0.3

    private var stream: FSEventStreamRef?
    private var watchedPath = ""
    private let onChange: @MainActor () -> Void

    init(onChange: @escaping @MainActor () -> Void) {
        self.onChange = onChange
    }

    func watch(_ directoryURL: URL) {
        let path = Self.comparablePath(for: directoryURL)
        guard path != watchedPath || stream == nil else { return }
        stop()
        watchedPath = path
        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passRetained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        let callback: FSEventStreamCallback = { _, info, _, eventPaths, _, _ in
            guard let info else { return }
            let changedPaths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] ?? []
            MainActor.assumeIsolated {
                let watcher = Unmanaged<DirectoryWatcher>.fromOpaque(info).takeUnretainedValue()
                watcher.handleChanges(at: changedPaths)
            }
        }
        let flags = kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagWatchRoot
        guard let newStream = FSEventStreamCreate(
            nil,
            callback,
            &context,
            [path] as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            Self.eventLatency,
            FSEventStreamCreateFlags(flags)
        ) else {
            return
        }
        FSEventStreamSetDispatchQueue(newStream, .main)
        FSEventStreamStart(newStream)
        stream = newStream
    }

    func stop() {
        guard let stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        Unmanaged.passUnretained(self).release()
        self.stream = nil
        watchedPath = ""
    }

    private static func comparablePath(for url: URL) -> String {
        url.resolvingSymlinksInPath().normalizedFilePath.lowercased()
    }

    private func handleChanges(at changedPaths: [String]) {
        let affectsWatchedDirectory = changedPaths.contains { changedPath in
            let changedURL = URL(fileURLWithPath: changedPath)
            return Self.comparablePath(for: changedURL) == watchedPath
                || Self.comparablePath(for: changedURL.deletingLastPathComponent()) == watchedPath
        }
        if affectsWatchedDirectory {
            onChange()
        }
    }
}
