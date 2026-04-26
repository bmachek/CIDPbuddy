import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:developer' as dev;
import 'backup_service.dart';
import 'cloud/google_drive_auth.dart';

/// Unique periodic-task identifiers used by WorkManager.
const String kBackupPeriodicTaskName = 'cidpbuddy_periodic_backup';
const String kBackupPeriodicTaskUniqueName = 'cidpbuddy_periodic_backup_v1';

/// Top-level dispatcher Flutter spawns inside the WorkManager isolate.
///
/// Must be a top-level / static function and tagged `vm:entry-point` so the
/// AOT compiler keeps the symbol.
@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      dev.log('BackupWorker: task=$task firing');
      // GoogleSignIn must be (re-)initialized in this isolate before the
      // Drive destination can fetch a token.
      if (GoogleDriveAuth.instance.isPlatformSupported) {
        await GoogleDriveAuth.instance.tryRestore();
      }
      final result = await BackupService().runBackup();
      if (result.success) {
        dev.log('BackupWorker: success ${result.fileName}');
        return true;
      }
      dev.log('BackupWorker: failed: ${result.error}');
      // Returning false signals WorkManager to apply backoff and retry.
      return false;
    } catch (e, stack) {
      dev.log('BackupWorker: uncaught: $e\n$stack');
      return false;
    }
  });
}

/// Helpers for the foreground process to manage the periodic registration.
class BackupScheduler {
  /// Initialize WorkManager. Safe to call multiple times.
  static Future<void> init() async {
    await Workmanager().initialize(backupCallbackDispatcher);
  }

  /// Register (or replace) the periodic backup task. Android's minimum
  /// interval is 15 minutes; we ask for 6 hours. The task itself skips
  /// when a recent backup already exists (see `BackupService._autoMinInterval`).
  static Future<void> enable() async {
    await Workmanager().registerPeriodicTask(
      kBackupPeriodicTaskUniqueName,
      kBackupPeriodicTaskName,
      frequency: const Duration(hours: 6),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 30),
    );
    dev.log('BackupScheduler: periodic task registered.');
  }

  static Future<void> disable() async {
    await Workmanager().cancelByUniqueName(kBackupPeriodicTaskUniqueName);
    dev.log('BackupScheduler: periodic task cancelled.');
  }

  /// Sync the WorkManager registration with current SharedPreferences state.
  /// Call this from `main()` and after the user toggles auto-backup.
  static Future<void> syncFromPrefs() async {
    final status = await BackupService().getStatus();
    if (status.enabled && status.destination != null) {
      await enable();
    } else {
      await disable();
    }
  }
}
