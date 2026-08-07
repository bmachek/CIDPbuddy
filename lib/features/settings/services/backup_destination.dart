import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

enum DestinationKind { local, saf }

/// Storage abstraction. Each destination owns its own access logic and
/// must implement a non-destructive [verifyAccess] healthcheck.
abstract class BackupDestination {
  static const _kPath = 'backup_directory_path';
  static const _kIsSaf = 'backup_is_saf';
  static const _kKind = 'backup_destination_kind';

  DestinationKind get kind;
  String get displayLabel;
  String get pathOrUri;

  /// What [persist] writes to prefs. Defaults to [pathOrUri]; destinations
  /// whose absolute path is not stable across app updates override this with
  /// a portable marker — see [appInternalMarker].
  String get persistedPathOrUri => pathOrUri;

  /// Whether backups here outlive the app itself. False for storage inside
  /// the app sandbox, which iOS erases together with the app.
  bool get isDurable => true;

  /// Roundtrip a tiny token file. Returns null on success, or a German
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

  /// iOS has no durable way to grant write access to an arbitrary
  /// externally-picked folder: `file_picker`'s `UIDocumentPickerViewController`
  /// only grants transient security-scoped access around the pick call
  /// itself (never persisted, no bookmark), so any later read/write on that
  /// path fails. On iOS backups therefore always live in this app-internal
  /// folder instead; users get a copy out via the Files app or share sheet.
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
  }

  static Future<BackupDestination?> load() async {
    final prefs = await SharedPreferences.getInstance();

    // iOS never trusts a persisted path: it's always our own auto-managed
    // internal folder (see [provisionAppInternal]), never user-picked, and
    // the app's Documents container UUID changes on every app update — a path
    // saved under the old container silently stops existing, so re-deriving
    // fresh here is both correct and self-healing.
    if (Platform.isIOS) {
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
          if (path != null && Platform.isAndroid) return SafDestination(path, displayName: name);
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
  String get displayLabel => dirPath;

  @override
  Future<String?> verifyAccess() async {
    final dir = Directory(dirPath);
    // Do NOT silently create the directory here. The restore flow re-uses
    // verifyAccess, and creating an empty dir would mask "I lost access to
    // the real folder" as "folder exists but contains no backups".
    bool exists;
    try {
      exists = await dir.exists();
    } catch (e) {
      return 'Ordner nicht lesbar: $dirPath\n($e)';
    }
    if (!exists) {
      return 'Ordner existiert nicht (mehr): $dirPath';
    }
    // Probe that we can actually read the directory contents — the sandbox
    // case where stat() succeeds but readdir() is denied is the trickiest.
    try {
      await dir.list().take(1).toList();
    } catch (e) {
      return 'Ordner nicht lesbar: $dirPath\n($e)';
    }
    try {
      final probe = File(p.join(dirPath, '.cidp_health'));
      await probe.writeAsString('ok', flush: true);
      await probe.delete();
    } catch (e) {
      return 'Schreibzugriff verweigert: $dirPath\n($e)';
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
      throw FileSystemException('Ordner existiert nicht', dirPath);
    }
    final entries = await dir.list().toList();
    final files = entries.whereType<File>().where((f) {
      final name = p.basename(f.path);
      return (name.startsWith('cidpbuddy_backup_') || name.startsWith('igkeeper_backup_')) && name.endsWith('.zip');
    }).map((f) {
      final stat = f.statSync();
      return BackupFile(
        name: p.basename(f.path),
        date: stat.modified,
        size: stat.size,
        pathOrUri: f.path,
        isSaf: false,
      );
    }).toList();
    files.sort((a, b) => b.date.compareTo(a.date));
    return files;
  }

  /// Diagnostic helper used by the restore UI when listBackups returns 0
  /// matches — surfaces what is actually in the folder so the user can tell
  /// "wrong folder" apart from "lost permission" apart from "weird filename".
  Future<String> describeContents() async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return 'Ordner existiert nicht.';
    try {
      final entries = await dir.list().toList();
      if (entries.isEmpty) return 'Ordner ist leer.';
      final names = entries
          .map((e) => p.basename(e.path))
          .where((n) => !n.startsWith('.'))
          .take(8)
          .toList();
      return 'Gefunden (${entries.length}): ${names.join(", ")}'
          '${entries.length > names.length ? ' …' : ''}';
    } catch (e) {
      return 'Ordner konnte nicht gelistet werden: $e';
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
  String get displayLabel => 'App-Ordner (Dateien-App → CIDP Buddy → Backups)';

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
  String get displayLabel =>
      displayName != null ? '$displayName (SAF)' : 'Cloud-/SAF-Ordner';

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
      return 'Berechtigung für Cloud-Ordner verloren. Bitte Ordner erneut wählen.';
    }
  }

  @override
  Future<void> writeBackup(String fileName, Uint8List bytes) async {
    final stream = SafStream();
    await stream.writeFileBytes(
      treeUri,
      fileName,
      'application/zip',
      bytes,
    );
  }

  @override
  Future<List<BackupFile>> listBackups() async {
    final util = SafUtil();
    final files = await util.list(treeUri);
    final result = files
        .where((f) =>
            (f.name.startsWith('cidpbuddy_backup_') || f.name.startsWith('igkeeper_backup_')) && f.name.endsWith('.zip'))
        .map((f) => BackupFile(
              name: f.name,
              date: DateTime.fromMillisecondsSinceEpoch(f.lastModified),
              size: f.length,
              pathOrUri: f.uri,
              isSaf: true,
            ))
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
    try {
      final util = SafUtil();
      final entries = await util.list(treeUri);
      if (entries.isEmpty) return 'SAF-Ordner ist leer.';
      final names = entries
          .map((f) => f.isDir ? '[${f.name}/]' : f.name)
          .take(8)
          .toList();
      return 'Gefunden (${entries.length}): ${names.join(", ")}'
          '${entries.length > names.length ? ' …' : ''}';
    } catch (e) {
      return 'SAF-Ordner konnte nicht gelistet werden: $e';
    }
  }
}
