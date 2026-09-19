import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/locale_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

/// A backup file located in some destination (local dir or SAF tree).
class BackupFile {
  final String name;
  final DateTime date;
  final int size;
  final String pathOrUri;
  final bool isSaf;

  BackupFile({
    required this.name,
    required this.date,
    required this.size,
    required this.pathOrUri,
    required this.isSaf,
  });
}

enum DestinationKind { local, saf, bookmark }

/// Storage abstraction. Each destination owns its own access logic and
/// must implement a non-destructive [verifyAccess] healthcheck.
abstract class BackupDestination {
  static const _kPath = 'backup_directory_path';
  static const _kIsSaf = 'backup_is_saf';
  static const _kKind = 'backup_destination_kind';

  /// Both names the app has written backups under. `igkeeper_` is the old
  /// one and still has to be recognised — a patient restoring after a phone
  /// change may hand us a folder filled years ago.
  static bool isBackupFileName(String name) =>
      (name.startsWith('cidpbuddy_backup_') ||
          name.startsWith('igkeeper_backup_')) &&
      name.endsWith('.zip');

  DestinationKind get kind;

  /// Human-readable name of this destination.
  ///
  /// Takes the translations explicitly rather than resolving them itself: the
  /// caller is always a widget that already has them, and a getter could not
  /// await the asynchronous lookup the service methods below use.
  String displayLabel(AppLocalizations l10n);

  String get pathOrUri;

  /// What [persist] writes to prefs. Defaults to [pathOrUri]; destinations
  /// whose absolute path is not stable across app updates override this with
  /// a portable marker — see [appInternalMarker].
  String get persistedPathOrUri => pathOrUri;

  /// Whether backups here outlive the app itself. False for storage inside
  /// the app sandbox, which iOS erases together with the app.
  bool get isDurable => true;

  /// Roundtrip a tiny token file. Returns null on success, or a translated
  /// error string suitable for user display on failure.
  Future<String?> verifyAccess();

  /// Write [bytes] as [fileName] to this destination.
  Future<void> writeBackup(String fileName, Uint8List bytes);

  Future<List<BackupFile>> listBackups();

  Future<Uint8List> readBackup(BackupFile file);

  Future<void> deleteBackup(BackupFile file);

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPath, persistedPathOrUri);
    await prefs.setBool(_kIsSaf, kind == DestinationKind.saf);
    await prefs.setString(_kKind, kind.name);
  }

  static const _kSafDisplayName = 'backup_saf_display_name';
  static const _kBookmarkName = 'backup_bookmark_folder_name';

  /// Persisted instead of an absolute path for the app-internal destination.
  ///
  /// iOS reassigns the app's data-container UUID on *every* app update, so a
  /// stored `/var/mobile/Containers/Data/Application/<uuid>/Documents/Backups`
  /// is dead the moment the app updates — pointing at a container that no
  /// longer exists. The marker carries no UUID and is resolved against the
  /// current container every time it is loaded.
  static const String appInternalMarker = 'app-documents:Backups';

  /// True for absolute paths inside *an* iOS app container. Such a path is
  /// only ever valid for the container that produced it, so one read back from
  /// prefs after an update must be re-resolved rather than trusted.
  static bool isContainerScopedPath(String path) =>
      path.contains('/Containers/Data/Application/');

  /// The iOS fallback destination, used until the patient picks a folder.
  ///
  /// `file_picker` cannot be that pick: its `UIDocumentPickerViewController`
  /// only grants transient security-scoped access around the pick call itself
  /// (never persisted, no bookmark), so any later read or write on that path
  /// fails. [BookmarkDestination] is the one that persists the access; this
  /// folder is where backups go while none has been picked, and it is erased
  /// together with the app — hence [AppInternalDestination.isDurable] false
  /// and the warning the settings screen shows for it.
  static Future<AppInternalDestination> provisionAppInternal() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'Backups'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return AppInternalDestination(dir.path);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPath);
    await prefs.remove(_kIsSaf);
    await prefs.remove(_kKind);
    await prefs.remove(_kSafDisplayName);
    await prefs.remove(_kBookmarkName);
  }

  static Future<BackupDestination?> load() async {
    final prefs = await SharedPreferences.getInstance();

    // iOS never trusts a persisted *path*: the app's Documents container UUID
    // changes on every app update, so a path saved under the old container
    // silently stops existing. A bookmark is the exception — it is not a path
    // but a token, and re-resolving it is exactly how it is meant to be used.
    if (Platform.isIOS) {
      if (prefs.getString(_kKind) == DestinationKind.bookmark.name) {
        final encoded = prefs.getString(_kPath);
        if (encoded != null) {
          return BookmarkDestination(
            base64Decode(encoded),
            displayName: prefs.getString(_kBookmarkName),
          );
        }
      }
      // Nothing picked (or the pick was cleared): fall back to the app's own
      // folder, re-derived against the current container, which is both
      // correct and self-healing.
      final destination = await provisionAppInternal();
      await destination.persist();
      return destination;
    }

    final kindStr = prefs.getString(_kKind);

    // New-style: explicit kind written by `persist()`.
    if (kindStr != null) {
      switch (kindStr) {
        case 'saf':
          final path = prefs.getString(_kPath);
          final name = prefs.getString(_kSafDisplayName);
          if (path != null && Platform.isAndroid) {
            return SafDestination(path, displayName: name);
          }
          return null;
        case 'local':
          final path = prefs.getString(_kPath);
          if (path == null) return null;
          return _resolveLocal(path);
      }
    }

    // Legacy fallback for installs predating the `_kKind` field.
    final path = prefs.getString(_kPath);
    if (path == null) return null;
    final isSaf = prefs.getBool(_kIsSaf) ?? false;
    if (isSaf && Platform.isAndroid) {
      final name = prefs.getString(_kSafDisplayName);
      return SafDestination(path, displayName: name);
    }
    return _resolveLocal(path);
  }

  /// Turns a persisted local value back into a usable destination. Both the
  /// portable marker and a stale absolute container path from an older release
  /// resolve to the app-internal folder in the *current* container.
  static Future<BackupDestination> _resolveLocal(String path) async {
    if (path == appInternalMarker || isContainerScopedPath(path)) {
      final destination = await provisionAppInternal();
      // Rewrite the stale absolute path so it is not read back again.
      await destination.persist();
      return destination;
    }
    return LocalDestination(path);
  }
}

class LocalDestination extends BackupDestination {
  final String dirPath;
  LocalDestination(this.dirPath);

  @override
  DestinationKind get kind => DestinationKind.local;

  @override
  String get pathOrUri => dirPath;

  @override
  String displayLabel(AppLocalizations l10n) => dirPath;

  @override
  Future<String?> verifyAccess() async {
    final l10n = await LocaleProvider.l10nForBackground();
    final dir = Directory(dirPath);
    // Do NOT silently create the directory here. The restore flow re-uses
    // verifyAccess, and creating an empty dir would mask "I lost access to
    // the real folder" as "folder exists but contains no backups".
    bool exists;
    try {
      exists = await dir.exists();
    } catch (e) {
      return l10n.backupFolderUnreadable(dirPath, '$e');
    }
    if (!exists) {
      return l10n.backupFolderMissing(dirPath);
    }
    // Probe that we can actually read the directory contents — the sandbox
    // case where stat() succeeds but readdir() is denied is the trickiest.
    try {
      await dir.list().take(1).toList();
    } catch (e) {
      return l10n.backupFolderUnreadable(dirPath, '$e');
    }
    try {
      final probe = File(p.join(dirPath, '.cidp_health'));
      await probe.writeAsString('ok', flush: true);
      await probe.delete();
    } catch (e) {
      return l10n.backupFolderNotWritable(dirPath, '$e');
    }
    return null;
  }

  @override
  Future<void> writeBackup(String fileName, Uint8List bytes) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) await dir.create(recursive: true);
    final tmp = File(p.join(dirPath, '$fileName.tmp'));
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(p.join(dirPath, fileName));
  }

  @override
  Future<List<BackupFile>> listBackups() async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      throw FileSystemException('Backup folder does not exist', dirPath);
    }
    final entries = await dir.list().toList();
    final files = entries
        .whereType<File>()
        .where((f) => BackupDestination.isBackupFileName(p.basename(f.path)))
        .map((f) {
          final stat = f.statSync();
          return BackupFile(
            name: p.basename(f.path),
            date: stat.modified,
            size: stat.size,
            pathOrUri: f.path,
            isSaf: false,
          );
        })
        .toList();
    files.sort((a, b) => b.date.compareTo(a.date));
    return files;
  }

  /// Diagnostic helper used by the restore UI when listBackups returns 0
  /// matches — surfaces what is actually in the folder so the user can tell
  /// "wrong folder" apart from "lost permission" apart from "weird filename".
  Future<String> describeContents() async {
    final l10n = await LocaleProvider.l10nForBackground();
    final dir = Directory(dirPath);
    if (!await dir.exists()) return l10n.backupFolderMissingShort;
    try {
      final entries = await dir.list().toList();
      if (entries.isEmpty) return l10n.backupFolderEmpty;
      final names = entries
          .map((e) => p.basename(e.path))
          .where((n) => !n.startsWith('.'))
          .take(8)
          .toList();
      return l10n.backupFolderContents(
        entries.length,
        names.join(', ') + (entries.length > names.length ? ' …' : ''),
      );
    } catch (e) {
      return l10n.backupFolderListFailed('$e');
    }
  }

  @override
  Future<Uint8List> readBackup(BackupFile file) async {
    return Uint8List.fromList(await File(file.pathOrUri).readAsBytes());
  }

  @override
  Future<void> deleteBackup(BackupFile file) async {
    final f = File(file.pathOrUri);
    if (await f.exists()) await f.delete();
  }
}

/// The app's own `Documents/Backups` folder.
///
/// Its absolute path embeds the iOS data-container UUID, which is reassigned
/// on every app update, so the path is never persisted — only
/// [BackupDestination.appInternalMarker] is, and it is resolved against the
/// current container on load.
///
/// Backups here are erased together with the app, so [isDurable] is false and
/// the UI must push the user to export a copy.
class AppInternalDestination extends LocalDestination {
  AppInternalDestination(super.dirPath);

  @override
  String get persistedPathOrUri => BackupDestination.appInternalMarker;

  @override
  String displayLabel(AppLocalizations l10n) => l10n.backupDestinationAppFolder;

  @override
  bool get isDurable => false;
}

class SafDestination extends BackupDestination {
  final String treeUri;
  final String? displayName;

  SafDestination(this.treeUri, {this.displayName});

  @override
  DestinationKind get kind => DestinationKind.saf;

  @override
  String get pathOrUri => treeUri;

  @override
  String displayLabel(AppLocalizations l10n) => displayName != null
      ? '$displayName (SAF)'
      : l10n.backupDestinationSafFolder;

  @override
  Future<void> persist() async {
    await super.persist();
    if (displayName != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(BackupDestination._kSafDisplayName, displayName!);
    }
  }

  static const _healthName = '.cidp_health';

  @override
  Future<String?> verifyAccess() async {
    try {
      final stream = SafStream();
      // Write a tiny token. saf_stream throws if the persistable URI grant
      // has expired or the provider revoked it.
      await stream.writeFileBytes(
        treeUri,
        _healthName,
        'application/octet-stream',
        Uint8List.fromList([0x4f, 0x4b]),
      );
      // Best-effort delete.
      try {
        final util = SafUtil();
        final files = await util.list(treeUri);
        for (final f in files) {
          if (f.name == _healthName) {
            await util.delete(f.uri, false);
          }
        }
      } catch (_) {}
      return null;
    } catch (e) {
      return (await LocaleProvider.l10nForBackground()).backupSafPermissionLost;
    }
  }

  @override
  Future<void> writeBackup(String fileName, Uint8List bytes) async {
    final stream = SafStream();
    await stream.writeFileBytes(treeUri, fileName, 'application/zip', bytes);
  }

  @override
  Future<List<BackupFile>> listBackups() async {
    final util = SafUtil();
    final files = await util.list(treeUri);
    final result = files
        .where((f) => BackupDestination.isBackupFileName(f.name))
        .map(
          (f) => BackupFile(
            name: f.name,
            date: DateTime.fromMillisecondsSinceEpoch(f.lastModified),
            size: f.length,
            pathOrUri: f.uri,
            isSaf: true,
          ),
        )
        .toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  @override
  Future<Uint8List> readBackup(BackupFile file) async {
    final stream = SafStream();
    final bytes = await stream.readFileBytes(file.pathOrUri);
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> deleteBackup(BackupFile file) async {
    final util = SafUtil();
    await util.delete(file.pathOrUri, false);
  }

  /// Diagnostic: shows what's actually in the SAF tree so the user can
  /// distinguish "wrong folder selected" from "files have unexpected names".
  Future<String> describeContents() async {
    final l10n = await LocaleProvider.l10nForBackground();
    try {
      final util = SafUtil();
      final entries = await util.list(treeUri);
      if (entries.isEmpty) return l10n.backupSafFolderEmpty;
      final names = entries
          .map((f) => f.isDir ? '[${f.name}/]' : f.name)
          .take(8)
          .toList();
      return l10n.backupFolderContents(
        entries.length,
        names.join(', ') + (entries.length > names.length ? ' …' : ''),
      );
    } catch (e) {
      return l10n.backupSafListFailed('$e');
    }
  }
}

/// A folder the patient picked in the iOS Files app.
///
/// The handle is not a path but a security-scoped bookmark, resolved on the
/// native side (`ios/Runner/BackupBookmarkPlugin.swift`). Backups written
/// here live outside the app sandbox, so they survive deleting or
/// reinstalling the app — and when the folder belongs to iCloud Drive,
/// Nextcloud or Dropbox, they leave the phone without anyone lifting a
/// finger. That is what makes an automatic export possible on iOS at all:
/// the share sheet needs a human, a bookmark does not.
class BookmarkDestination extends BackupDestination {
  BookmarkDestination(this._bookmark, {String? displayName})
    : _displayName = displayName;

  static const MethodChannel _channel = MethodChannel(
    'de.fokuspunk.cidpbuddy/backup_bookmark',
  );

  /// iOS hands out a fresh token when the folder moved, and the old one stops
  /// resolving soon after — so this is not final, and every refresh is
  /// persisted immediately.
  Uint8List _bookmark;
  String? _displayName;

  /// Opens the iOS folder picker. Returns null when the patient cancels;
  /// throws a [PlatformException] when the pick itself fails.
  static Future<BookmarkDestination?> pick() async {
    final reply = await _channel.invokeMapMethod<String, Object?>(
      'pickDirectory',
    );
    final bookmark = reply?['bookmark'];
    if (bookmark is! Uint8List) return null;
    return BookmarkDestination(
      bookmark,
      displayName: reply?['value'] as String?,
    );
  }

  @override
  DestinationKind get kind => DestinationKind.bookmark;

  @override
  String get pathOrUri => base64Encode(_bookmark);

  @override
  String displayLabel(AppLocalizations l10n) =>
      _displayName ?? l10n.backupDestinationPickedFolder;

  @override
  Future<void> persist() async {
    await super.persist();
    final prefs = await SharedPreferences.getInstance();
    final name = _displayName;
    if (name != null) {
      await prefs.setString(BackupDestination._kBookmarkName, name);
    } else {
      await prefs.remove(BackupDestination._kBookmarkName);
    }
  }

  /// Sends one call to the native side. Every reply may carry a refreshed
  /// bookmark; persisting it on the spot is what keeps the destination alive
  /// when the folder moves.
  Future<Object?> _invoke(
    String method, {
    String? name,
    Uint8List? bytes,
  }) async {
    final reply = await _channel.invokeMapMethod<String, Object?>(method, {
      'bookmark': _bookmark,
      'name': ?name,
      'bytes': ?bytes,
    });
    if (reply == null) return null;
    final refreshed = reply['bookmark'];
    if (refreshed is Uint8List) {
      _bookmark = refreshed;
      await persist();
    }
    return reply['value'];
  }

  @override
  Future<String?> verifyAccess() async {
    final l10n = await LocaleProvider.l10nForBackground();
    try {
      final name = await _invoke('verify');
      // The folder may have been renamed since it was picked; showing the
      // name it has now beats showing the one it had then.
      if (name is String && name.isNotEmpty && name != _displayName) {
        _displayName = name;
        await persist();
      }
      return null;
    } on PlatformException catch (e) {
      return e.code == 'access_denied'
          ? l10n.backupBookmarkAccessLost
          : l10n.backupFolderNotWritable(
              displayLabel(l10n),
              e.message ?? e.code,
            );
    }
  }

  @override
  Future<void> writeBackup(String fileName, Uint8List bytes) async {
    await _invoke('write', name: fileName, bytes: bytes);
  }

  @override
  Future<List<BackupFile>> listBackups() async {
    final entries = await _invoke('list');
    final files = <BackupFile>[];
    for (final entry in entries is List ? entries : const []) {
      final row = entry as Map;
      final name = row['name'] as String? ?? '';
      if (!BackupDestination.isBackupFileName(name)) continue;
      files.add(
        BackupFile(
          name: name,
          date: DateTime.fromMillisecondsSinceEpoch(
            row['modified'] as int? ?? 0,
          ),
          // 0 for a backup iCloud has not downloaded to this phone yet. The
          // restore list leaves the size out instead of claiming "0.0 MB";
          // reading it downloads the file first.
          size: row['size'] as int? ?? 0,
          // The file name *is* the handle here — the folder it belongs to
          // comes from the bookmark, not from a path.
          pathOrUri: name,
          isSaf: false,
        ),
      );
    }
    files.sort((a, b) => b.date.compareTo(a.date));
    return files;
  }

  @override
  Future<Uint8List> readBackup(BackupFile file) async {
    final bytes = await _invoke('read', name: file.name);
    if (bytes is! Uint8List) {
      throw FileSystemException('Backup could not be read', file.name);
    }
    return bytes;
  }

  @override
  Future<void> deleteBackup(BackupFile file) async {
    await _invoke('delete', name: file.name);
  }
}
