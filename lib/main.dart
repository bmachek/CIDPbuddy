import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:cidpbuddy/core/database/database.dart';
import 'package:cidpbuddy/features/inventory/providers/inventory_provider.dart';
import 'package:cidpbuddy/features/diary/providers/diary_provider.dart';
import 'package:cidpbuddy/core/theme/app_theme.dart';
import 'package:cidpbuddy/core/theme/theme_provider.dart';
import 'package:cidpbuddy/features/reminders/services/notification_service.dart';
import 'package:cidpbuddy/core/services/scheduler_service.dart';
import 'package:cidpbuddy/core/services/medication_service.dart';
import 'package:cidpbuddy/core/services/background_service.dart';
import 'package:cidpbuddy/features/settings/services/backup_service.dart';
import 'package:cidpbuddy/features/settings/services/backup_worker.dart';
import 'package:cidpbuddy/core/l10n/locale_provider.dart';
import 'package:cidpbuddy/l10n/generated/app_localizations.dart';
import 'package:cidpbuddy/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force Flutter to build & expose the semantics tree so UI-test tools
  // (Maestro) can find widgets by text/id without a screen reader running.
  SemanticsBinding.instance.ensureSemantics();

  // Month and weekday names for every language we ship. Loaded before the
  // first frame so `DateFormat` never falls back to en_US mid-render, and so
  // background isolates spawned from here inherit the data.
  await initializeDateFormatting();

  // Read the stored language before `runApp`, otherwise the first frame
  // renders in the system language and then visibly switches.
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  try {
    final db = AppDatabase();
    // Notifications must be initialized before runApp so cold-launches from a
    // notification tap can route correctly. Everything else is deferred.
    await NotificationService().init();

    runApp(
      MultiProvider(
        providers: [
          Provider.value(value: db),
          Provider(create: (_) => MedicationService(db)),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: localeProvider),
          ChangeNotifierProxyProvider<AppDatabase, InventoryProvider>(
            create: (context) => InventoryProvider(db),
            update: (context, database, previous) =>
                InventoryProvider(database),
          ),
          ChangeNotifierProxyProvider<AppDatabase, DiaryProvider>(
            create: (context) => DiaryProvider(db),
            update: (context, database, previous) => DiaryProvider(database),
          ),
        ],
        child: const CIDPBuddyApp(),
      ),
    );

    // Defer heavy init (WorkManager, alarm rescheduling, battery-opt prompt,
    // missed-treatments scan) until after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initDeferred(db));
    });
  } catch (e, stack) {
    debugPrint('Initialization error: $e');
    debugPrint('Stack trace: $stack');
    // Fallback to minimal app to show error if possible. The widget tree that
    // would normally provide translations never got built, so the message is
    // looked up directly against the resolved locale.
    String message;
    try {
      message = (await LocaleProvider.l10nForBackground()).startupFailed('$e');
    } catch (_) {
      message = 'The app could not be initialized:\n$e';
    }
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(message),
            ),
          ),
        ),
      ),
    );
  }
}

/// Runs after the first frame. Each step is independently guarded so a
/// failure in one (e.g. WorkManager not available on the platform) does not
/// block the others.
Future<void> _initDeferred(AppDatabase db) async {
  Future<void> step(String name, Future<void> Function() body) async {
    try {
      await body();
    } catch (e, stack) {
      debugPrint('Deferred init "$name" failed: $e\n$stack');
    }
  }

  await step('BackgroundService', BackgroundService.initialize);
  await step('BackupScheduler.init', BackupScheduler.init);
  await step('BackupScheduler.syncFromPrefs', BackupScheduler.syncFromPrefs);
  await step(
    'BackupScheduler.enableMissedCheck',
    BackupScheduler.enableMissedCheck,
  );

  // Self-heal orphaned schedules, planned infusions, supply links and orders
  // (e.g. left behind by a restore whose backup referenced a medication absent
  // from the restored state, or by deletes in earlier builds). Schedules are
  // removed first so the following sync cannot regenerate entries from them;
  // runs before the missed-treatment scan so orphans never surface as
  // actionless rows.
  await step('cleanupOrphans', () async {
    final removedSchedules = await db.deleteOrphanedSchedules();
    final removedPlanned = await db.deleteOrphanedPlannedInfusions();
    final removedLinks = await db.deleteOrphanedLinksAndOrders();
    if (removedSchedules > 0 || removedPlanned > 0 || removedLinks > 0) {
      debugPrint(
        'Removed $removedSchedules orphaned schedule(s), '
        '$removedPlanned orphaned planned infusion(s) and '
        '$removedLinks orphaned supply link/order row(s) on startup.',
      );
    }
  });

  final scheduler = SchedulerService(db);
  await step('syncPlannedInfusions', scheduler.syncPlannedInfusions);
  await step('checkMissedTreatments', scheduler.checkMissedTreatments);

  if (Platform.isAndroid) {
    await step('batteryOptimization', () async {
      final disabled =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled ??
          false;
      if (!disabled) {
        await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
      }
    });
  }

  await step('backupReminder', () async {
    final prefs = await SharedPreferences.getInstance();
    final autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? false;
    if (!autoBackupEnabled) {
      await NotificationService().scheduleBackupReminder();
    } else {
      await NotificationService().cancelBackupReminder();
      unawaited(BackupService().checkSafAccessOnStartup());
    }
  });
}

class CIDPBuddyApp extends StatelessWidget {
  const CIDPBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // null means "follow the device", which hands resolution to the callback
      // below.
      locale: localeProvider.locale,
      // Flutter's default resolution falls back to `supportedLocales.first`,
      // and gen-l10n orders that list alphabetically — so a device set to,
      // say, Japanese would land on German. English is the documented
      // fallback, so pick it explicitly.
      localeListResolutionCallback: (deviceLocales, supported) {
        for (final device in deviceLocales ?? const <Locale>[]) {
          for (final candidate in supported) {
            if (candidate.languageCode == device.languageCode) return candidate;
          }
        }
        return const Locale('en');
      },
      home: const MainScreen(),
    );
  }
}
