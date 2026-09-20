import Flutter
import UIKit
import UniformTypeIdentifiers

/// The iOS counterpart of Android's Storage Access Framework: a folder the
/// patient picks once in the Files app and that the app keeps writing backups
/// into afterwards — iCloud Drive, Nextcloud, Dropbox, a plugged-in drive,
/// anything that shows up there — including from the background task.
///
/// The mechanism is the *security-scoped bookmark*. The URL that
/// `UIDocumentPickerViewController` hands back is accessible only inside the
/// delegate callback; `bookmarkData()` turns it into a token that survives
/// relaunches, and resolving that token re-acquires access for as long as the
/// folder exists. Everything below is a thin wrapper around it: the Dart side
/// keeps the token, this side turns it back into file operations.
///
/// Every operation goes through `NSFileCoordinator`. The picked folder
/// normally belongs to a file provider that syncs it behind the app's back,
/// an uncoordinated write races that sync, and a coordinated *read* is what
/// pulls down an iCloud file that exists only as a placeholder on this device
/// — the state every backup is in on a fresh phone, which is when restoring
/// matters most.
class BackupBookmarkPlugin: NSObject, FlutterPlugin {
  private static let channelName = "de.fokuspunk.cidpbuddy/backup_bookmark"

  /// Written and deleted again by `verify` to prove the folder is still
  /// writable. Same name as the probe the Android and desktop destinations
  /// use, so the folder never collects two kinds of stray token file.
  private static let healthFileName = ".cidp_health"

  /// File work runs off the platform thread: a backup is megabytes of ZIP,
  /// and a coordinated read of an undownloaded iCloud file waits for the
  /// network. Both would otherwise block the UI — or deadlock against the
  /// file coordinator, which needs the main thread to deliver its callbacks.
  private let queue = DispatchQueue(
    label: "de.fokuspunk.cidpbuddy.backup-bookmark",
    qos: .userInitiated
  )

  /// The pending `pickDirectory` reply. The document picker answers through
  /// its delegate, long after the method call returned.
  private var pendingPick: FlutterResult?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(BackupBookmarkPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "pickDirectory" {
      pickDirectory(result: result)
      return
    }

    let arguments = call.arguments as? [String: Any]
    guard let bookmark = (arguments?["bookmark"] as? FlutterStandardTypedData)?.data
    else {
      reply(result, with: BookmarkError.invalidArguments)
      return
    }
    let name = arguments?["name"] as? String
    let bytes = (arguments?["bytes"] as? FlutterStandardTypedData)?.data
    let method = call.method

    run(result) {
      try self.withFolder(bookmark) { folder in
        switch method {
        case "verify":
          let probe = folder.appendingPathComponent(Self.healthFileName)
          try Self.writeFile(Data("ok".utf8), to: probe)
          try? Self.deleteFile(probe)
          // The folder may have been renamed since it was picked; the caller
          // shows this, so it never displays a name that no longer exists.
          return folder.lastPathComponent
        case "write":
          guard let name, let bytes else { throw BookmarkError.invalidArguments }
          try Self.writeFile(bytes, to: folder.appendingPathComponent(name))
          return nil
        case "list":
          return try Self.listFiles(in: folder)
        case "read":
          guard let name else { throw BookmarkError.invalidArguments }
          let data = try Self.readFile(name, in: folder)
          return FlutterStandardTypedData(bytes: data)
        case "delete":
          guard let name else { throw BookmarkError.invalidArguments }
          try Self.deleteFile(folder.appendingPathComponent(name))
          return nil
        default:
          throw BookmarkError.unsupported(method)
        }
      }
    }
  }

  // MARK: - Folder picking

  private func pickDirectory(result: @escaping FlutterResult) {
    guard let presenter = Self.topViewController() else {
      reply(result, with: BookmarkError.noWindow)
      return
    }
    guard pendingPick == nil else {
      reply(result, with: BookmarkError.busy)
      return
    }
    pendingPick = result

    let picker = UIDocumentPickerViewController(
      forOpeningContentTypes: [.folder],
      asCopy: false
    )
    picker.delegate = self
    picker.allowsMultipleSelection = false
    presenter.present(picker, animated: true)
  }

  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window =
      scenes.first { $0.activationState == .foregroundActive }?.keyWindow
      ?? scenes.first?.keyWindow
    var controller = window?.rootViewController
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    return controller
  }

  // MARK: - Bookmark plumbing

  /// Resolves [bookmark], runs [body] with the folder accessible, and packs
  /// the answer for the channel: `value` is the operation's result, the
  /// optional `bookmark` a refreshed token.
  ///
  /// iOS reports a bookmark as stale when the folder moved or its provider
  /// re-created it. The token still resolves that one time, and the fresh one
  /// goes back to the Dart side to be persisted — a bookmark that is never
  /// refreshed eventually stops resolving, and the backups stop with it.
  private func withFolder(
    _ bookmark: Data,
    _ body: (URL) throws -> Any?
  ) throws -> [String: Any] {
    var isStale = false
    let folder: URL
    do {
      folder = try URL(
        resolvingBookmarkData: bookmark,
        options: [],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      )
    } catch {
      throw BookmarkError.accessDenied
    }
    guard folder.startAccessingSecurityScopedResource() else {
      throw BookmarkError.accessDenied
    }
    defer { folder.stopAccessingSecurityScopedResource() }

    var payload: [String: Any] = [:]
    if let value = try body(folder) {
      payload["value"] = value
    }
    if isStale,
      let refreshed = try? folder.bookmarkData(
        options: [],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
    {
      payload["bookmark"] = FlutterStandardTypedData(bytes: refreshed)
    }
    return payload
  }

  private func run(
    _ result: @escaping FlutterResult,
    _ body: @escaping () throws -> [String: Any]
  ) {
    queue.async {
      do {
        let payload = try body()
        DispatchQueue.main.async { result(payload) }
      } catch {
        let code = (error as? BookmarkError)?.code ?? "io_error"
        let message = error.localizedDescription
        DispatchQueue.main.async {
          result(FlutterError(code: code, message: message, details: nil))
        }
      }
    }
  }

  private func reply(_ result: @escaping FlutterResult, with error: BookmarkError) {
    result(
      FlutterError(code: error.code, message: error.localizedDescription, details: nil)
    )
  }

  // MARK: - Coordinated file operations

  private static func writeFile(_ data: Data, to url: URL) throws {
    var coordinatorError: NSError?
    var writeError: Error?
    NSFileCoordinator().coordinate(
      writingItemAt: url,
      options: .forReplacing,
      error: &coordinatorError
    ) { target in
      do {
        try data.write(to: target, options: .atomic)
      } catch {
        writeError = error
      }
    }
    if let coordinatorError { throw coordinatorError }
    if let writeError { throw writeError }
  }

  private static func deleteFile(_ url: URL) throws {
    var coordinatorError: NSError?
    var deleteError: Error?
    NSFileCoordinator().coordinate(
      writingItemAt: url,
      options: .forDeleting,
      error: &coordinatorError
    ) { target in
      do {
        try FileManager.default.removeItem(at: target)
      } catch {
        deleteError = error
      }
    }
    if let coordinatorError { throw coordinatorError }
    if let deleteError { throw deleteError }
  }

  private static func readFile(_ name: String, in folder: URL) throws -> Data {
    let file = folder.appendingPathComponent(name)
    if !FileManager.default.fileExists(atPath: file.path) {
      // Only a placeholder on this device: ask the provider for the real
      // file. The coordinated read below then waits until it has landed.
      try? FileManager.default.startDownloadingUbiquitousItem(at: file)
    }

    var coordinatorError: NSError?
    var readError: Error?
    var data: Data?
    NSFileCoordinator().coordinate(
      readingItemAt: file,
      options: [],
      error: &coordinatorError
    ) { target in
      do {
        data = try Data(contentsOf: target)
      } catch {
        readError = error
      }
    }
    if let coordinatorError { throw coordinatorError }
    if let readError { throw readError }
    guard let data else { throw BookmarkError.notFound(name) }
    return data
  }

  private static func listFiles(in folder: URL) throws -> [[String: Any]] {
    var coordinatorError: NSError?
    var listError: Error?
    var entries: [[String: Any]] = []
    NSFileCoordinator().coordinate(
      readingItemAt: folder,
      options: [],
      error: &coordinatorError
    ) { directory in
      do {
        let urls = try FileManager.default.contentsOfDirectory(
          at: directory,
          includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
          options: []
        )
        for url in urls {
          let placeholder = isPlaceholder(url)
          let name = displayName(of: url)
          // Hidden files (the health probe among them) are not backups. The
          // check runs on the resolved name, so an iCloud placeholder — which
          // is hidden by definition — is kept.
          if name.hasPrefix(".") { continue }
          let values = try? url.resourceValues(
            forKeys: [.contentModificationDateKey, .fileSizeKey]
          )
          let modified = values?.contentModificationDate ?? Date(timeIntervalSince1970: 0)
          entries.append([
            "name": name,
            // A placeholder is a few hundred bytes and says nothing about the
            // backup behind it, so its size is reported as unknown rather
            // than as a suspiciously tiny file.
            "size": placeholder ? 0 : (values?.fileSize ?? 0),
            "modified": Int(modified.timeIntervalSince1970 * 1000),
            "placeholder": placeholder,
          ])
        }
      } catch {
        listError = error
      }
    }
    if let coordinatorError { throw coordinatorError }
    if let listError { throw listError }
    return entries
  }

  /// iCloud keeps a file that is not downloaded here as a hidden
  /// `.name.zip.icloud` stub. The backup exists — it just has to be fetched
  /// before it can be read — so the stub is reported under the name it
  /// stands for.
  private static func isPlaceholder(_ url: URL) -> Bool {
    let name = url.lastPathComponent
    return name.hasPrefix(".") && name.hasSuffix(".icloud")
  }

  private static func displayName(of url: URL) -> String {
    let name = url.lastPathComponent
    guard isPlaceholder(url) else { return name }
    return String(name.dropFirst().dropLast(".icloud".count))
  }
}

// MARK: - Picker delegate

extension BackupBookmarkPlugin: UIDocumentPickerDelegate {
  func documentPicker(
    _ controller: UIDocumentPickerViewController,
    didPickDocumentsAt urls: [URL]
  ) {
    guard let result = pendingPick else { return }
    pendingPick = nil
    guard let folder = urls.first else {
      result(nil)
      return
    }

    // The picked URL is accessible only inside this callback; the bookmark is
    // what outlives it.
    let scoped = folder.startAccessingSecurityScopedResource()
    defer { if scoped { folder.stopAccessingSecurityScopedResource() } }
    do {
      let bookmark = try folder.bookmarkData(
        options: [],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      result([
        "bookmark": FlutterStandardTypedData(bytes: bookmark),
        "value": folder.lastPathComponent,
      ])
    } catch {
      result(
        FlutterError(
          code: BookmarkError.bookmarkFailed.code,
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    pendingPick?(nil)
    pendingPick = nil
  }
}

// MARK: - Errors

/// The `code` is what the Dart side matches on; the message is for the log,
/// never for the patient — user-facing text is translated over there.
private enum BookmarkError: LocalizedError {
  case invalidArguments
  case accessDenied
  case notFound(String)
  case unsupported(String)
  case bookmarkFailed
  case noWindow
  case busy

  var code: String {
    switch self {
    case .invalidArguments: return "invalid_arguments"
    case .accessDenied: return "access_denied"
    case .notFound: return "not_found"
    case .unsupported: return "unsupported"
    case .bookmarkFailed: return "bookmark_failed"
    case .noWindow: return "no_window"
    case .busy: return "busy"
    }
  }

  var errorDescription: String? {
    switch self {
    case .invalidArguments:
      return "Missing or malformed arguments."
    case .accessDenied:
      return "The app no longer has access to the picked backup folder."
    case .notFound(let name):
      return "\(name) does not exist in the picked backup folder."
    case .unsupported(let method):
      return "Unsupported method \(method)."
    case .bookmarkFailed:
      return "Could not create a bookmark for the picked folder."
    case .noWindow:
      return "No view controller to present the folder picker from."
    case .busy:
      return "A folder picker is already open."
    }
  }
}
