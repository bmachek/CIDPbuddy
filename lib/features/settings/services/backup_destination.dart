import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:saf_util/saf_util.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;
import 'cloud/google_drive_destination.dart';

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

enum DestinationKind { local, saf, googleDrive, iCloud }

/// Storage abstraction. Each destination owns its own access logic and
/// must implement a non-destructive [verifyAccess] healthcheck.
abstract class BackupDestination {
  static const _kPath = 'backup_directory_path';
  static const _kIsSaf = 'backup_is_saf';
  static const _kKind = 'backup_destination_kind';

  DestinationKind get kind;
  String get displayLabel;
  String get pathOrUri;

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
    await prefs.setString(_kPath, pathOrUri);
    await prefs.setBool(_kIsSaf, kind == DestinationKind.saf);
    await prefs.setString(_kKind, kind.name);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPath);
    await prefs.remove(_kIsSaf);
    await prefs.remove(_kKind);
    // Cloud-specific cleanup. Imported lazily to avoid a hard dep cycle here.
    await GoogleDriveDestination.clearStored();
  }

  static Future<BackupDestination?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final kindStr = prefs.getString(_kKind);

    // New-style: explicit kind written by `persist()`.
    if (kindStr != null) {
      switch (kindStr) {
        case 'googleDrive':
          return GoogleDriveDestination.tryLoad();
        case 'saf':
          final path = prefs.getString(_kPath);
          if (path != null && Platform.isAndroid) return SafDestination(path);
          return null;
        case 'local':
          final path = prefs.getString(_kPath);
          if (path != null) return LocalDestination(path);
          return null;
        case 'iCloud':
          // Reserved for the iOS implementation. See ICloudDestination.
          return null;
      }
    }

    // Legacy fallback for installs predating the `_kKind` field.
    final path = prefs.getString(_kPath);
    if (path == null) return null;
    final isSaf = prefs.getBool(_kIsSaf) ?? false;
    if (isSaf && Platform.isAndroid) return SafDestination(path);
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
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        try {
          await dir.create(recursive: true);
        } catch (e) {
          return 'Verzeichnis nicht zugänglich.';
        }
      }
      final probe = File(p.join(dirPath, '.cidp_health'));
      await probe.writeAsString('ok', flush: true);
      await probe.delete();
      return null;
    } catch (e) {
      dev.log('LocalDestination.verifyAccess failed: $e');
      return 'Schreibzugriff verweigert.';
    }
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
    if (!await dir.exists()) return [];
    final entries = await dir.list().toList();
    final files = entries.whereType<File>().where((f) {
      final name = p.basename(f.path);
      return name.startsWith('igkeeper_backup_') && name.endsWith('.zip');
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

class SafDestination extends BackupDestination {
  final String treeUri;
  SafDestination(this.treeUri);

  @override
  DestinationKind get kind => DestinationKind.saf;

  @override
  String get pathOrUri => treeUri;

  @override
  String get displayLabel => 'Cloud-/SAF-Ordner';

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
      } catch (e) {
        dev.log('SafDestination: cleanup of $_healthName failed (non-fatal): $e');
      }
      return null;
    } catch (e) {
      dev.log('SafDestination.verifyAccess failed: $e');
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
            f.name.startsWith('igkeeper_backup_') && f.name.endsWith('.zip'))
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
}
