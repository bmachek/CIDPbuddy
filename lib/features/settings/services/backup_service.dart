import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:saf_util/saf_util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;
import '../../reminders/services/notification_service.dart';
import 'backup_destination.dart';
import 'cloud/google_drive_auth.dart';
import 'cloud/google_drive_destination.dart';

export 'backup_destination.dart' show BackupFile, BackupDestination, DestinationKind;

/// Result of a backup attempt — used by UI / WorkManager / reliability check.
class BackupResult {
  final bool success;
  final String? error;
  final String? fileName;
  BackupResult.ok(this.fileName) : success = true, error = null;
  BackupResult.fail(this.error) : success = false, fileName = null;
}

/// Snapshot of the current backup configuration + state for UI display.
class BackupStatus {
  final bool enabled;
  final BackupDestination? destination;
  final DateTime? lastSuccess;
  final DateTime? lastAttempt;
  final String? lastError;
  final int consecutiveFailures;

  const BackupStatus({
    required this.enabled,
    required this.destination,
    required this.lastSuccess,
    required this.lastAttempt,
    required this.lastError,
    required this.consecutiveFailures,
  });

  bool get isHealthy =>
      destination != null && lastError == null && consecutiveFailures == 0;
}

class BackupService {
  // Pref keys (kept compatible with previous releases for upgrade path).
  static const String kAutoBackupEnabled = 'auto_backup_enabled';
  static const String kBackupDirectoryPath = 'backup_directory_path';
  static const String kBackupIsSaf = 'backup_is_saf';
  static const String kLastBackupTime = 'last_backup_time';
  // New state keys.
  static const String _kLastAttempt = 'backup_last_attempt_at';
  static const String _kLastError = 'backup_last_error';
  static const String _kConsecutiveFailures = 'backup_consecutive_failures';

  /// Number of consecutive failures before we surface a notification.
  static const int _failureNotifyThreshold = 2;

  /// Skip an automatic backup if a successful one happened more recently than
  /// this. Manual ("Test now") backups bypass this.
  static const Duration _autoMinInterval = Duration(hours: 6);

  /// Keep this many of the most recent backups; older ones are pruned.
  static const int _retainCount = 5;

  static final BackupService _instance = BackupService._();
  factory BackupService() => _instance;
  BackupService._();

  // ---------------------------------------------------------------- Status

  Future<BackupStatus> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final dest = await BackupDestination.load();
    return BackupStatus(
      enabled: prefs.getBool(kAutoBackupEnabled) ?? false,
      destination: dest,
      lastSuccess: _readDate(prefs, kLastBackupTime),
      lastAttempt: _readDate(prefs, _kLastAttempt),
      lastError: prefs.getString(_kLastError),
      consecutiveFailures: prefs.getInt(_kConsecutiveFailures) ?? 0,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kAutoBackupEnabled, enabled);
  }

  DateTime? _readDate(SharedPreferences prefs, String key) {
    final s = prefs.getString(key);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  // ---------------------------------------------------- Destination picking

  /// Picks an Android SAF tree (cloud or local) — preferred path on Android.
  Future<BackupDestination?> pickSafBackupDirectory() async {
    if (!Platform.isAndroid) return null;
    try {
      final util = SafUtil();
      final dir = await util.pickDirectory(
        writePermission: true,
        persistablePermission: true,
      );
      if (dir == null) return null;
      final destination = SafDestination(dir.uri, displayName: dir.name);
      // Verify before persisting — confirms the grant is actually usable.
      final err = await destination.verifyAccess();
      if (err != null) {
        dev.log('BackupService: SAF picked but verify failed: $err');
        return null;
      }
      await destination.persist();
      await _resetFailureState();
      return destination;
    } catch (e, stack) {
      dev.log('BackupService.pickSafBackupDirectory: $e\n$stack');
      return null;
    }
  }

  /// Sign in with Google and use the user's Drive `appDataFolder` as the
  /// backup target. Available on Android, iOS and macOS.
  Future<BackupDestination?> pickGoogleDriveBackup() async {
    if (!GoogleDriveAuth.instance.isPlatformSupported) return null;
    try {
      final account = await GoogleDriveAuth.instance.signInAndAuthorize();
      if (account == null) return null;
      final destination = GoogleDriveDestination(account.email);
      final err = await destination.verifyAccess();
      if (err != null) {
        dev.log('BackupService: Drive picked but verify failed: $err');
        return null;
      }
      await destination.persist();
      await _resetFailureState();
      return destination;
    } catch (e, stack) {
      dev.log('BackupService.pickGoogleDriveBackup: $e\n$stack');
      return null;
    }
  }

  /// Plain filesystem directory — used on desktop or as Android fallback.
  Future<BackupDestination?> pickLocalBackupDirectory() async {
    try {
      final selected = await FilePicker.platform.getDirectoryPath();
      if (selected == null) return null;
      final destination = LocalDestination(selected);
      final err = await destination.verifyAccess();
      if (err != null) {
        dev.log('BackupService: Local picked but verify failed: $err');
        return null;
      }
      await destination.persist();
      await _resetFailureState();
      return destination;
    } catch (e) {
      dev.log('BackupService.pickLocalBackupDirectory: $e');
      return null;
    }
  }

  Future<void> clearDestination() async {
    await BackupDestination.clear();
    await _resetFailureState();
  }

  // ------------------------------------------------------------ Run backup

  /// Runs a backup. Used by the in-app debounce, the WorkManager periodic
  /// task, and the manual "Backup jetzt testen" button.
  ///
  /// Always updates state; surfaces a failure notification once
  /// [_failureNotifyThreshold] consecutive failures are reached.
  Future<BackupResult> runBackup({bool manual = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastAttempt, DateTime.now().toIso8601String());

    final dest = await BackupDestination.load();
    if (dest == null) {
      return _recordFailure(prefs, 'Kein Backup-Ziel ausgewählt.');
    }

    if (!manual && !(prefs.getBool(kAutoBackupEnabled) ?? false)) {
      return BackupResult.fail('Automatisches Backup ist deaktiviert.');
    }

    // Skip if a recent success exists, but only for automatic runs.
    if (!manual) {
      final lastSuccess = _readDate(prefs, kLastBackupTime);
      if (lastSuccess != null &&
          DateTime.now().difference(lastSuccess) < _autoMinInterval) {
        return BackupResult.fail('Übersprungen: aktuelles Backup vorhanden.');
      }
    }

    final verifyError = await dest.verifyAccess();
    if (verifyError != null) {
      return _recordFailure(prefs, verifyError);
    }

    try {
      final fileName = _generateFileName();
      final zipBytes = await _buildZipInMemory();

      await dest.writeBackup(fileName, zipBytes);
      await _pruneOldBackups(dest);

      await prefs.setString(kLastBackupTime, DateTime.now().toIso8601String());
      await prefs.remove(_kLastError);
      await prefs.setInt(_kConsecutiveFailures, 0);
      // If we previously notified about failure, clear the badge.
      await NotificationService().cancelBackupFailureNotification();
      return BackupResult.ok(fileName);
    } catch (e, stack) {
      dev.log('BackupService.runBackup write failed: $e\n$stack');
      return _recordFailure(prefs, 'Schreibfehler: $e');
    }
  }

  Future<BackupResult> _recordFailure(
      SharedPreferences prefs, String error) async {
    final failures = (prefs.getInt(_kConsecutiveFailures) ?? 0) + 1;
    await prefs.setInt(_kConsecutiveFailures, failures);
    await prefs.setString(_kLastError, error);
    if (failures >= _failureNotifyThreshold) {
      await NotificationService().showBackupFailureNotification(error);
    }
    return BackupResult.fail(error);
  }

  Future<void> _resetFailureState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastError);
    await prefs.setInt(_kConsecutiveFailures, 0);
    await NotificationService().cancelBackupFailureNotification();
  }

  String _generateFileName() {
    final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'igkeeper_backup_$ts.zip';
  }

  /// Builds the backup archive in memory. Includes the SQLite DB plus any
  /// `charge_*` photos in the documents dir.
  Future<Uint8List> _buildZipInMemory() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'igkeeper.sqlite'));
    if (!await dbFile.exists()) {
      throw StateError('Quelldatenbank nicht gefunden.');
    }

    final tempDir = await getTemporaryDirectory();
    final tempZipPath =
        p.join(tempDir.path, 'cidp_backup_${DateTime.now().microsecondsSinceEpoch}.zip');

    final encoder = ZipFileEncoder();
    encoder.create(tempZipPath);
    try {
      await encoder.addFile(dbFile);
      // sqlite3 sidecar files — copy them too if present so the backup is
      // a complete snapshot even when WAL hasn't been checkpointed.
      for (final suffix in const ['-wal', '-shm']) {
        final side = File(p.join(dbFolder.path, 'igkeeper.sqlite$suffix'));
        if (await side.exists()) {
          await encoder.addFile(side);
        }
      }
      final entries = await dbFolder.list().toList();
      for (final f in entries.whereType<File>()) {
        final name = p.basename(f.path);
        if (name.startsWith('charge_')) {
          await encoder.addFile(f);
        }
      }
    } finally {
      encoder.close();
    }

    final tempZip = File(tempZipPath);
    final bytes = await tempZip.readAsBytes();
    try {
      await tempZip.delete();
    } catch (_) {/* best-effort */}
    return bytes;
  }

  Future<void> _pruneOldBackups(BackupDestination dest) async {
    try {
      final list = await dest.listBackups();
      if (list.length <= _retainCount) return;
      final toDelete = list.skip(_retainCount).toList();
      for (final f in toDelete) {
        try {
          await dest.deleteBackup(f);
          dev.log('BackupService: pruned ${f.name}');
        } catch (e) {
          dev.log('BackupService: prune failed for ${f.name}: $e');
        }
      }
    } catch (e) {
      dev.log('BackupService._pruneOldBackups: $e');
    }
  }

  // -------------------------------------------------- List & restore & legacy

  Future<List<BackupFile>> getAvailableBackups() async {
    final dest = await BackupDestination.load();
    if (dest == null) return [];
    try {
      return await dest.listBackups();
    } catch (e) {
      dev.log('BackupService.getAvailableBackups: $e');
      return [];
    }
  }

  /// Restores the given backup atomically: the destination DB file is replaced
  /// only after a successful, fully written `.tmp` copy.
  Future<bool> restoreFromZippedBackup(BackupFile backup) async {
    try {
      dev.log('BackupService.restore: ${backup.name}');
      final dest = await BackupDestination.load();
      if (dest == null) return false;
      final bytes = await dest.readBackup(backup);
      if (bytes.isEmpty) return false;

      final archive = ZipDecoder().decodeBytes(bytes);
      final dbFolder = await getApplicationDocumentsDirectory();
      bool dbRestored = false;

      // Two-phase write: stage all files as `.tmp`, then rename.
      final staged = <File>[];
      try {
        for (final entry in archive) {
          if (!entry.isFile) continue;
          final data = entry.content as List<int>;
          final outPath = p.join(dbFolder.path, entry.name);
          final tmp = File('$outPath.restore_tmp');
          await tmp.writeAsBytes(data, flush: true);
          staged.add(tmp);
        }
        for (final tmp in staged) {
          final finalPath =
              tmp.path.substring(0, tmp.path.length - '.restore_tmp'.length);
          final finalFile = File(finalPath);
          if (await finalFile.exists()) await finalFile.delete();
          await tmp.rename(finalPath);
          if (p.basename(finalPath) == 'igkeeper.sqlite') dbRestored = true;
        }
      } catch (e) {
        dev.log('BackupService.restore staging failed: $e');
        for (final tmp in staged) {
          try {
            if (await tmp.exists()) await tmp.delete();
          } catch (_) {}
        }
        rethrow;
      }

      return dbRestored;
    } catch (e, stack) {
      dev.log('BackupService.restore exception: $e\n$stack');
      return false;
    }
  }

  /// Legacy "share the raw .sqlite" feature — kept for export-via-share.
  Future<void> exportDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'igkeeper.sqlite'));
    if (!await dbFile.exists()) return;

    final tempDir = await getTemporaryDirectory();
    final backupPath = p.join(tempDir.path, 'igkeeper_backup.sqlite');
    final tempFile = await dbFile.copy(backupPath);

    await Share.shareXFiles(
      [XFile(tempFile.path)],
      subject: 'CIDP Buddy Backup',
      text:
          'Sicherung der CIDP-Buddy-Datenbank vom ${DateTime.now().toLocal()}',
    );
  }

  /// Legacy single-file import via FilePicker (e.g. from older exports).
  Future<bool> importDatabase() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.single.path == null) return false;
    final pickedFile = File(result.files.single.path!);
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'igkeeper.sqlite'));
    final tmp = File('${dbFile.path}.restore_tmp');
    await pickedFile.copy(tmp.path);
    if (await dbFile.exists()) await dbFile.delete();
    await tmp.rename(dbFile.path);
    return true;
  }

  // ---------------------------------------------------------- Compatibility

  /// Old call site (`tableUpdates().listen → autoBackup`) — kept so existing
  /// hookups continue to work, just delegates to [runBackup].
  Future<void> autoBackup() async {
    await runBackup(manual: false);
  }

  /// Checks SAF access once on app startup to detect revoked pCloud/SAF
  /// permissions before the next scheduled WorkManager run. Skips if a
  /// recent successful backup exists or if a failure is already recorded.
  Future<void> checkSafAccessOnStartup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(kAutoBackupEnabled) ?? false)) return;
      final dest = await BackupDestination.load();
      if (dest == null || dest.kind != DestinationKind.saf) return;

      // Skip if already in a known error state — WorkManager handles retries.
      if (prefs.getString(_kLastError) != null) return;

      // Skip if a recent backup proves access still works.
      final lastSuccess = _readDate(prefs, kLastBackupTime);
      if (lastSuccess != null &&
          DateTime.now().difference(lastSuccess) < const Duration(hours: 12)) {
        return;
      }

      final error = await dest.verifyAccess();
      if (error != null) {
        dev.log('BackupService: Startup SAF check failed: $error');
        await _recordFailure(prefs, error);
      }
    } catch (e) {
      dev.log('BackupService.checkSafAccessOnStartup: $e');
    }
  }
}
